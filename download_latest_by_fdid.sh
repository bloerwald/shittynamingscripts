#!/bin/bash
set -uo pipefail
scriptfile=$(greadlink -f ${BASH_SOURCE}); scriptdir="${scriptfile%/*}"

source "${scriptdir}/file.inc"

for fdid in ${@}
do
  while read filename; read chash
  do
  	echo "Downloading ${chash} to ${fdid}-${filename//\//--}"
  	download_latest_by_chash "${chash}" > "${fdid}-${filename//\//--}"
  done < <(filename_and_latest_chash ${fdid})
done
