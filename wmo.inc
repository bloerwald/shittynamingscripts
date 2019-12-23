#!/bin/bash
scriptfile=$(greadlink -f ${BASH_SOURCE}); scriptdir="${scriptfile%/*}"

source "${scriptdir}/dbc.inc"

wmoareatable=$(mktemp)
latest_dbc wmoareatable > "${wmoareatable}"
areatable=$(mktemp)
latest_dbc areatable > "${areatable}"

listfile_wmoonly=$(mktemp)
listfile_all \
  | grep 'world/wmo/.*wmo$' \
  > "${listfile_wmoonly}"

function root_filename_by_wmoid()
{
  local wm=$1
  grep "^${wm};" wmoid_state.csv \
    | grep -v /autogen-names/ \
    | sed -e 's,;, ,' -e 's,;, ,' \
    | while read _ fdid _
      do
        grep "^${fdid};" "${listfile_wmoonly}" | sed -e 's,^[0-9]*;,,'
      done \
    | head -n1
}

function guess_wmo_name()
{
  local wm=$1
  ( grep ^[^,]*,[0-9]*,$wm,0,-1 "${wmoareatable}" | sed -e 's-,.*--' \
  ; grep ^[^,]*,[0-9]*,$wm, "${wmoareatable}" \
      | grep -v ',0,[0-9]*$' \
      | sed -e 's-.*,\([0-9]*\),[0-9]*$-\1-' \
      | sort \
      | uniq -c \
      | sort -nr \
      | head -n1 \
      | while read _ aid; do grep ^$aid, "${areatable}" ; done \
      | sed -e 's-^[0-9]*,\([^,]*\),.*-\1-' \
  ; echo unknown
  ) | grep -v ^$ | head -n1
}

function get_wmo_json() {
  local build=$1
  local fdid=$2
  curl -s "https://wow.tools/files/scripts/preview_api.php?buildconfig=$build&filedataid=$fdid" \
    | tail -n +14 \
    | ghead -n -3 \
    | sed -e 's,.*tabpanel.*height.*<code>,,'
}

function get_wmoid() {
  get_wmo_json ${@} | python3 -c 'import html,sys,json
blob=html.unescape(sys.stdin.read())
if blob[0] != "{":
  sys.exit(0)
x=json.loads(blob)
print(x["header"]["areaTableID"])'
}
