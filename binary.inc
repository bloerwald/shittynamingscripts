#!/bin/bash

function read_uint32_t()
{
  local file="${1}"; shift
  local offset=$((${@}))
  echo $(( $( xxd -s ${offset} -g 4 -l 4 -e "${file}" \
            | sed -e 's,^[0-9a-f]*: ,0x,' -e 's, .*,,'
        )  ))
}

function read_c3vector()
{
  local file="${1}"; shift
  local offset=$((${@}))
  xxd -s ${offset} -g 1 -l 12 "${file}" \
    | sed -e 's,^[0-9a-f]*,000,' \
    | xxd -r \
    | od -f \
    | head -n 1 \
    | sed -e 's,000* *,,'
}

function chunk_magic()
{
  local as_str="${1}"
  echo $((0x$(echo -n "${as_str}" | xxd -ps -c 4)))
}

function require_uint32_t()
{
  local file="${1}"
  local offset=$((${2}))
  local value=$((${3}))
  if [[ $(read_uint32_t "${file}" "${offset}") != "${value}" ]]
  then
    echo "at ${file}:${offset}: expected ${value}" >&2
    exit 1
  fi
}
