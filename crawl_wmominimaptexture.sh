#!/bin/bash
set -uo pipefail
scriptfile=$(greadlink -f ${BASH_SOURCE}); scriptdir="${scriptfile%/*}"

source "${scriptdir}/dbc.inc"
source "${scriptdir}/file.inc"
source "${scriptdir}/wmo.inc"

function unique_fdids()
{
	latest_dbc wmominimaptexture \
    | tail -n +2 \
	  | sed -e 's-^[0-9]*,--' \
	  | sort -u \
	  | sed -e 's-,- -g' \
	  | tac
}

listfile_wmominionly=$(mktemp)
listfile_all \
  | grep 'world/minimaps/wmo/.*blp$' \
  > "${listfile_wmominionly}"
listfile_wmominionly_noautogen=$(mktemp)
cat "${listfile_wmominionly}" \
  | grep -v world/minimaps/wmo/autogen-names/ \
  > "${listfile_wmominionly_noautogen}"
listfile_autogenunknowns=$(mktemp)
cat "${listfile_wmominionly}" \
  | grep world/minimaps/wmo/autogen-names/unknown/ \
  > "${listfile_autogenunknowns}"

unique_fdids \
  | while read g x y fd wm
    do
  		if grep -q "^$fd;" "${listfile_wmominionly_noautogen}"
  		then
  			continue
  		fi
      root_fn=$(root_filename_by_wmoid $wm || true)
      fn_guess=
      if [[ "${root_fn}" == "" ]]
      then
    		guess="$(guess_wmo_name $wm | tr '[:upper:]' '[:lower:]')"
    		if [[ "${guess}" == "unknown" ]] && grep -q "^$fd;" "${listfile_autogenunknowns}"
    		then
    			continue
    		fi
      	fn_guess=$(printf "world/minimaps/wmo/autogen-names/%s/%s_%03d_%02d_%02d.blp\n" \
      	  "${guess}" $wm $g $x $y)
      else
        fn_guess=$(printf "%s_%03d_%02d_%02d.blp\n" \
          "$(sed -e 's,.wmo$,,' -e 's,^world/wmo/,world/minimaps/wmo/,' <<< "${root_fn}")" $g $x $y)
      fi
      suggest "$fd" "$fn_guess"
    done
