#!/bin/bash

function filename_and_latest_chash()
{
	local fdid=${1}
	while read line_with_filename; read line_with_chash
	do
		echo ${line_with_filename} \
		  | sed -e 's,.*Filename</td><td>,,' -e 's,</td></tr>.*,,'
		(tidy -q <<< "${line_with_chash}" 2>/dev/null || true) \
		  | grep fillChashModal \
		  | head -n1 \
		  | sed -e 's,.*fillChashModal..,,' -e 's,".*,,'
		break
	done < <(curl -s "https://wow.tools/files/scripts/filedata_api.php?filedataid=${fdid}" | head -n2)
}

function latest_chash()
{
	local fdid=${1}
	while read line_with_chash
	do
		(tidy -q <<< "${line_with_chash}" 2>/dev/null || true) \
		  | grep fillChashModal \
		  | head -n1 \
		  | sed -e 's,.*fillChashModal..,,' -e 's,".*,,'
		break
	done < <(curl -s "https://wow.tools/files/scripts/filedata_api.php?filedataid=${fdid}" | head -n2 | tail -n1)
}

function download_latest_by_chash()
{
  local chash=$1
  curl -s "https://wow.tools/casc/file/chash?contenthash=${chash}"
}

function listfile_all()
{
  curl -s https://wow.tools/casc/listfile/download/csv/unverified
}

listfile=$(mktemp)
listfile_all \
  > "${listfile}"

function search_files()
{
  local searchterm="$1"
  local start=$2
  local length=$3
  local dir=$4
  curl -s "https://wow.tools/files/scripts/api.php?draw=1&order[0][column]=0&order[0][dir]=${dir}&start=${start}&length=${length}&search[value]=${searchterm}&search[regex]=false&_=$(date +%s)" \
    | python -c 'import json,sys
x=json.load(sys.stdin)
for y in x["data"]:
  for z in y[3]:
    print("{} {} {}".format(y[0], z["buildconfig"], y[1] or y[7]))'
}

function search_files_only_latest()
{
  local searchterm="$1"
  local start=$2
  local length=$3
  local dir=$4
  curl -s "https://wow.tools/files/scripts/api.php?draw=1&order[0][column]=0&order[0][dir]=${dir}&start=${start}&length=${length}&search[value]=${searchterm}&search[regex]=false&_=$(date +%s)" \
    | python -c 'import json,sys
x=json.load(sys.stdin)
def first(y):
  for z in y[3]:
    if z["buildconfig"] == "bf24b9d67a4a9c7cc0ce59d63df459a8":
      continue
    print("{} {} {}".format(y[0], z["buildconfig"], y[1] or y[7]))
    return

for y in x["data"]:
  first(y)'
}

function suggest()
{
  local fdid="${1}"
  local fname="${2}"
  if ! grep -qi "^${fdid};${fname}$" "${listfile}"
  then
    echo "${fdid};${fname}"
  fi
}
