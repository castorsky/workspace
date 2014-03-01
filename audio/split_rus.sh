#!/usr/bin/env bash
find . -iname "*.cue" | while read FNAME
do
    FILE=`basename "$FNAME"`
    DIR=`dirname "$FNAME"`
    CURDIR=`pwd`
    cd "$DIR"
    cue2tracks -R -c ogg -f cp1251 -Q 8 -C -o "%D - %A/%N" "$FILE"; cd "$CURDIR"
done
