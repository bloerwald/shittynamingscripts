#!/bin/bash
set -euo pipefail
scriptfile=$(greadlink -f ${BASH_SOURCE}); scriptdir="${scriptfile%/*}"

source "${scriptdir}/file.inc"
source "${scriptdir}/wmo.inc"

function get_raw() {
	get_wmo_json ${@} | python3 -c 'import html,sys,json
blob=html.unescape(sys.stdin.read())
if blob[0] != "{":
	sys.exit(0)
x=json.loads(blob)
print(x["header"]["areaTableID"])
ng=x["header"]["nGroups"]
nl=x["header"]["nLod"]
li=0
ag=x["groupFileDataIDs"]
for l in [ag[i:i + ng] for i in range(0, len(ag), ng)]:
	for g in range(0,len(l)):
		if l[g] == 0: continue
		print("{} {:0>3}{}.wmo".format(l[g], g, "" if li == 0 else "_lod{}".format(li)))
	li += 1
print("foo end")'
}

listfile_wmoonly=$(mktemp)
listfile_all \
   | grep "world/wmo/.*wmo$" \
   > "${listfile_wmoonly}"
listfile_wmoonly_no_autonamed=$(mktemp)
listfile_all \
   | grep "world/wmo/.*wmo$" \
   | (grep -v '/autogen-names/' || true) \
   > "${listfile_wmoonly_no_autonamed}"

#search_files 'world/wmo/draenor/orc/6or_garrison_inn_v3_sno' 0 100 asc \
#search_files 'type:wmo' 200 100 desc \
#search_files 'type%3Awmo,unnamed' 0 100 asc \

search_files 'type:wmo,unnamed' 0 1199789 desc \
  | while read fd build _
    do
		get_raw $build $fd \
		  | while read wm; do
		  	  name="$(guess_wmo_name $wm)"
          if [[ "${name}" == "unknown" ]]
          then
            continue
          fi
		  	  if grep -q "^$fd;" "${listfile_wmoonly_no_autonamed}"
		  	  then
		  	  	pref=$(grep "^$fd;" "${listfile_wmoonly_no_autonamed}" | sed -e "s,^$fd;,," -e 's,.wmo$,,')
		  	  	echo "named root $fd $pref" >&2
		  	  else
		  	  	pref=$(printf "world/wmo/autogen-names/%s/%s" "$name" $wm)
            suggest $fd "${pref}.wmo"
		  	  fi
		      while read gfd suf
		      do
            #echo $gfd $pref $suf >&2
            if [[ "${gfd} ${suf}" == "foo end" ]]; then break; fi
            suggest $gfd "${pref}_${suf}"
		      done
		    done
    done
