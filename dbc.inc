#!/bin/bash

function latest_dbc()
{
  local table=$1
  curl -s "https://wow.tools/dbc/?dbc=${table}" \
    | grep -A 1 "'buildFilter'" \
    | tail -n1 \
    | sed -e "s,.*value=',https://wow.tools/api/export/?name=${table}\&build=," -e "s,'.*,," \
    | xargs curl -s
}
