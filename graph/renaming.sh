#!/bin/bash
USAGE="Usage: $0 start_range basename_wildcard"
if [ "$#" == "0" ]; then
	echo "$USAGE"
	exit 1
fi

ITER=$1
shift
for FILE in "$@"; do
	PREFIX=$(printf "%04d" $ITER)
	mv "${FILE}" "${PREFIX}_${FILE}"
	ITER=$(echo $ITER+2 | bc)
done
