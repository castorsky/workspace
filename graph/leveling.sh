#!/bin/bash
USAGE="Usage: $0 image_fomat(extension)"
if [ "$#" == "0" ]; then
	echo "$USAGE"
	exit 1
fi

MAXPROC=$(nproc)
FORMAT=$1
export FORMAT
CONVERT=`type -p convert`
export CONVERT

METHOD="-grayscale Rec709Luminance -level 23%,70%,1.1" # Libero 1993 manual
#METHOD="-quality 95% -level 23%,90%,0.7" # Javabook
export METHOD

if [ -z $CONVERT ]; then echo "Is ImageMagick installed?"; exit 1; fi

adjust_levels() {
	# $1 = image file
	DIR=`dirname $1`
	NAME=`basename $1 .${FORMAT}`
	$CONVERT "$DIR/$NAME.$FORMAT" $METHOD "$DIR/${NAME}_adjusted.$FORMAT"
}
export -f adjust_levels
find . -iname "*.$FORMAT" -print0 | \
	xargs -L 1 -P $MAXPROC -0 -I{} bash -c "adjust_levels \"{}\""
