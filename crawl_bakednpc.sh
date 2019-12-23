#!/bin/bash
set -euo pipefail
scriptfile=$(greadlink -f ${BASH_SOURCE}); scriptdir="${scriptfile%/*}"

source "${scriptdir}/dbc.inc"
source "${scriptdir}/file.inc"

listfile_bakednpconly=$(mktemp)
listfile_all \
  | grep 'textures/bakednpctextures/.*blp$' \
  > "${listfile_bakednpconly}"

creaturedisplayinfoextra=$(mktemp)
latest_dbc creaturedisplayinfoextra > "${creaturedisplayinfoextra}"

( IFS=, \
; latest_dbc texturefiledata \
 	| tac \
 	| while read fdid t m; do
 		grep ",$m," "${creaturedisplayinfoextra}" \
 		  | while read cdie          b hb   ; do
 		  	fname="textures/bakednpctextures/creaturedisplayextra-$cdie$([[ $b == $m ]] && echo; [[ $hb == $m ]] && echo _hd)$([[ $t == 0 ]] && echo; [[ $t == 1 ]] && echo _s; [[ $t == 2 ]] && echo _e).blp"
		if grep -q "^$fdid;" "${listfile_bakednpconly}"
		then
			echo "KNOWN $fdid $fname" >&2
			continue
		fi
 		echo "$fdid;$fname"
done; done)
