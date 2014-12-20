#!/bin/sh
convert_file() {
  COMMENTS=$(vorbiscomment -l "$1")
  for TAG in TITLE ARTIST ALBUM ALBUMARTIST \
             DATE TRACKNUMBER TRACKTOTAL GENRE DISCID
  do
    export TAG_$TAG="$(echo "$COMMENTS" | grep ^"${TAG}=" | awk -F "=" '{print $2}')"
  done
  echo "Processing file: $1"
  oggdec "$1" -Q -o - | oggenc -Q -q 4 -o "$1.new" -
  vorbiscomment -w -t "TITLE=$TAG_TITLE" -t "ARTIST=$TAG_ARTIST" \
                   -t "ALBUM=$TAG_ALBUM" -t "ALBUMARTIST=$TAG_ALBUMARTIST" \
                   -t "DATE=$TAG_DATE" -t "TRACKNUMBER=$TAG_TRACKNUMBER" \
                   -t "TRACKTOTAL=$TAG_TRACKTOTAL" -t "GENRE=$TAG_GENRE" \
                   -t "DISCID=$TAG_DISCID" "$1.new"
  mv -f "$1.new" "$1"
}

export -f convert_file
MAXPROC=$(nproc)
find . -iname "*.ogg" -print0 | \
  xargs -L 1 -P $MAXPROC -0 -I{} bash -c "convert_file \"{}\""
