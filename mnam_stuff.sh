#!/bin/bash
set -euo pipefail
scriptfile=$(greadlink -f ${BASH_SOURCE}); scriptdir="${scriptfile%/*}"

source "${scriptdir}/binary.inc"

file="${1}"

echo "## ${1}"

offset=0x28044

if [[ $(read_uint32_t 0x28044) == 1297040454 ]]
then
	offset=$((offset + 0x48))
fi
chunksize=$(read_uint32_t offset + 4)
offset=$((offset + 0x8))

_a_count=$(read_uint32_t offset + 0)
_b_count=$(read_uint32_t offset + 4)
offset=$((offset + 0x8))

if [[ ${_a_count} != 1 ]]
then
	echo "UNEXPECTED _a_count = ${_a_count}"
	exit 1
fi

for (( b = 0; b < ${_b_count}; b++ ))
do
	_c=$(read_uint32_t ${offset})
	offset=$((offset+4))

# char _d_unk[0x90];   /// id vvvvv
# float _e, _f;
# char _g_unk[0x90];
# int _g_unk2a;
# int _g_unk2b;
# float _g1, _g2;
# char _h_unk[0x90];
# int _h_unk2a;
# int _h_unk2b;
# float _h1, _h2;
# int _ia;
# int _ib;
# int _ic;
# int _id;
# float _j;
# int _k;
# float _la;
# int _lb;
# int _lc;
# float _ld;
# int _m;
# float _na;
# int _nb;
# int _nc;
# float _nd;
# int _o;
# float _p;
# int _q;              /// id ^^^^^
	size_of_unknown_blob=$((0x90+4+4+0x90+4+4+4+4+0x90+4+4+4+4+4+4+4+4+4+4+4+4+4+4+4+4+4+4+4+4+4+4))
	diff <(xxd -p -s $((offset)) -l ${size_of_unknown_blob} "${file}") \
	     	     /dev/stdin <<EOF
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000803f0000
803f00000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000803f0000803f000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000803f0000803f0000000000000000
00000000000000000000803f060000000000803f00000000000000000000
803f060000000000803f00000000000000000000803f060000000000803f
01000000
EOF
	offset=$((offset+size_of_unknown_blob))

	_r=$(read_uint32_t ${offset})
	offset=$((offset+4))
	echo ${_r}

	size_of_unknown_blob=$((4))
	diff <(xxd -p -s $((offset)) -l ${size_of_unknown_blob} "${file}") \
	     	     /dev/stdin <<EOF
00000000
EOF
	offset=$((offset+size_of_unknown_blob))

	_t_count=$(read_uint32_t ${offset})
	offset=$((offset+4))

	for (( t = 0; t < ${_t_count}; t++ ))
	do
		#echo $(read_c3vector offset)
		diff <(xxd -p -s $((offset + 0xC)) -l $((0xC)) "${file}") \
	    	 /dev/stdin <<EOF
00000000000000000000803f
EOF
		offset=$((offset + 24))
	done
done
