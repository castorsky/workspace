#!/bin/bash
# Check all needed executables
if [ ! -e /usr/bin/oggdec ]; then echo "Install Vorbistools package."; exit 1; fi
if [ ! -e /usr/bin/lame ]; then echo "Install LAME package."; exit 1; fi
if [ ! -e /usr/bin/id3v2 ]; then echo "Install ID3V2 package."; exit 1; fi
CYR_SUPPORT=`iconv -l | grep -c "CP1251"`
if [ $CYR_SUPPORT = "0" ]; then echo "ICONV cannot convert to CP1251"; exit 1; fi


export OUTPREFIX="/data/OUTPUT"
export DECODER="/usr/bin/oggdec"
export ENCODER="/usr/bin/lame -b 192"

convert_track() {
    COMMENTS=$(vorbiscomment -l "$1")
    for TAG in TITLE ARTIST ALBUM ALBUMARTIST DATE TRACKNUMBER TRACKTOTAL GENRE DISCID
    do
        export TAG_$TAG="$(echo "$COMMENTS" | grep ^"${TAG}=" | awk -F "=" '{print $2}' | iconv -f UTF8 -t CP1251)"
    done
    echo "Processing file: $1"
    BASE=`basename "$1" .ogg`
    DIR=`dirname "$1"`
    ${DECODER} -Q -o - "$1" | ${ENCODER} - "$DIR/$BASE.mp3"
    id3v2 -2 -a "$TAG_ARTIST" -A "$TAG_ALBUM" -t "$TAG_TITLE" -g "$TAG_GENRE" -y "$TAG_DATE" -T "$TAG_TRACKNUMBER/$TAG_TRACKTOTAL" "$DIR/$BASE.mp3"
    rm -f "$1"
}
export -f convert_track

MAXPROC=$(nproc)
find . -iname "*.ogg" -print0 | \
  xargs -L 1 -P $MAXPROC -0 -I{} bash -c "convert_track \"{}\""

exit 0
