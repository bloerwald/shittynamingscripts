#!/bin/bash
set -euo pipefail
scriptfile=$(greadlink -f ${BASH_SOURCE}); scriptdir="${scriptfile%/*}"

source "${scriptdir}/file.inc"

search_files_only_latest 'type:wdt' 0 4000 desc \
  | grep -vE '_(lgt|occ|fogs|mpv).wdt$' \
  | while read fdid build fname
    do
      file="${fdid}-${fname//\//--}"
      while read _; read chash
      do
        echo "Downloading ${chash} to ${file}" >&2
        download_latest_by_chash "${chash}" > "${file}"
      done < <(filename_and_latest_chash ${fdid})

      if ! "${scriptdir}/crawl_wdt-single.sh" "${file}" "${fname}"
      then
        echo "failed: ${file} ${fname}" >&2
      fi
    done
  done
