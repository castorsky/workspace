#!/bin/sh

# Unpack RARs
for I in *
do
    unrar x -pru-board "$I"
    rm -f "$I"
done

# Rename dirs
for A in *
do
    NAEM=`echo "$A" | sed -e 's/upd //'`
    mv "$A" "$NAEM"
done

# Start SFXs with DosBox
for DIR in *
do
    P=`pwd`
    cd "$DIR"
    mv *.EXE UPDATE.EXE
    dosbox -exit UPDATE.EXE
    rm -f UPDATE.EXE
    cd "$P"
done