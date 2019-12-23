#!/bin/bash
set -euo pipefail
scriptfile=$(greadlink -f ${BASH_SOURCE}); scriptdir="${scriptfile%/*}"

source "${scriptdir}/binary.inc"

file="${1}"
fname="${2}"

echo "## ${fname}" >&2

basename=$(basename -s .wdt "${fname}")
basedir="world/maps/${basename}"

require_uint32_t "${file}" 0x0000 $(chunk_magic 'MVER')
require_uint32_t "${file}" 0x0004 0x4
require_uint32_t "${file}" 0x0008 0x12

require_uint32_t "${file}" 0x000C $(chunk_magic 'MPHD')
require_uint32_t "${file}" 0x0010 0x20

function maybe_file_ref()
{
  local offset=${1}
  local would_be_name="${2}"

  local fdid=$(read_uint32_t "${file}" ${offset})
  if [[ ${fdid} != 0 ]]; then echo "${fdid};${would_be_name}"; fi
}

# flags=$(read_uint32_t "${file}" 0x0014)

maybe_file_ref 0x0018 "${basedir}/${basename}_lgt.wdt"
maybe_file_ref 0x001c "${basedir}/${basename}_occ.wdt"
maybe_file_ref 0x0020 "${basedir}/${basename}_fogs.wdt"
maybe_file_ref 0x0024 "${basedir}/${basename}_mpv.wdt"
maybe_file_ref 0x0028 "${basedir}/${basename}.tex"
maybe_file_ref 0x002c "${basedir}/${basename}.wdl"
maybe_file_ref 0x0030 "${basedir}/${basename}.pd4"

require_uint32_t "${file}" 0x0034 $(chunk_magic 'MAIN')
require_uint32_t "${file}" 0x0038 0x8000

require_uint32_t "${file}" 0x803c $(chunk_magic 'MAID')
require_uint32_t "${file}" 0x8040 0x20000

offset=0x8044
for (( y = 0; y < 64; y++ )); do
  for (( x = 0; x < 64; x++ )); do
    if ! diff -q <(xxd -p -s $((offset)) -l $((0x20)) "${file}") /dev/stdin 2>/dev/null >/dev/null <<EOF
000000000000000000000000000000000000000000000000000000000000
0000
EOF
    then
      xp=$(printf "%02d" ${x})
      yp=$(printf "%02d" ${y})
      maybe_file_ref $((${offset} + 0x00)) "${basedir}/${basename}_${x}_${y}.adt"
      maybe_file_ref $((${offset} + 0x04)) "${basedir}/${basename}_${x}_${y}_obj0.adt"
      maybe_file_ref $((${offset} + 0x08)) "${basedir}/${basename}_${x}_${y}_obj1.adt"
      maybe_file_ref $((${offset} + 0x0c)) "${basedir}/${basename}_${x}_${y}_tex0.adt"
      maybe_file_ref $((${offset} + 0x10)) "${basedir}/${basename}_${x}_${y}_lod.adt"
      maybe_file_ref $((${offset} + 0x14)) "world/maptextures/${basename}/${basename}_${xp}_${yp}.blp"
      maybe_file_ref $((${offset} + 0x18)) "world/maptextures/${basename}/${basename}_${xp}_${yp}_n.blp"
      maybe_file_ref $((${offset} + 0x1c)) "world/minimaps/${basename}/map${xp}_${yp}.blp"
    fi
    offset=$((${offset} + 0x20))
  done
done
