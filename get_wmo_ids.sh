#!/bin/bash
set -euo pipefail
scriptfile=$(greadlink -f ${BASH_SOURCE}); scriptdir="${scriptfile%/*}"

source "${scriptdir}/file.inc"
source "${scriptdir}/wmo.inc"

#search_files 'world/wmo/draenor/orc/6or_garrison_inn_v3_sno' 0 100 asc \
#search_files 'type:wmo' 200 100 desc \
#search_files 'type%3Awmo,unnamed' 0 100 asc \

search_files_only_latest 'type:wmo' 0 10096 desc \
  | grep -v '_lod[0-9].wmo$' \
  | while read fd build fname
    do
      if ! grep -q ";$fd;$fname;" wmoid_state.csv
      then
        echo $fd $fname $build >&2
        (get_wmoid $build $fd || true) \
          | while read wm; do
              echo "$wm;$fd;$fname;$(guess_wmo_name $wm)" | tee /dev/stderr >> wmoid_state.csv
            done
      fi
    done
