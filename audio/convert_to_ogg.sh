#!/bin/sh

# Check all needed executables
if [ ! -e /usr/bin/flac ]; then echo "Install FLAC package."; exit 1; fi
if [ ! -e /usr/bin/oggenc ]; then echo "Install Vorbistools package."; exit 1; fi

# Define tags which are to be read from original files
export TAGLIST="TITLE ARTIST ALBUM ALBUMARTIST DATE TRACKNUMBER TRACKTOTAL GENRE DISCID"

# Display help message if script was triggered with -h parameter
show_help() {
cat << EOF
Usage: ${0##*/} [-hiq]
Convert all files in current directory (recursively) from FLAC/Ogg to Ogg Vorbis.
WARNING! Original files will be deleted!
    -h          display this help and exit
    -i          enable conversion to CP-1251 codepage
    -q          set quality of output Ogg file (default = 8)
EOF
}

# Main function
convert_file() {
    # If script was triggered with -i parameter enable conversion
    echo "Converting file $1"
    # Detect filetype
    EXT=`basename "$1" | sed -E 's/.*\.([A-Za-z0-9]{1,})/\1/'`
    DECODE=""
    COMMENTS=""
    case $EXT in
        ogg)
            DECODE="oggdec \"$1\" -Q -o -"
            COMMENTS=$(vorbiscomment -l "$1")
            ;;
        flac)
            DECODE="flac -sdc \"$1\""
            COMMENTS=$(metaflac --export-tags-to=- "$1")
            ;;
    esac
    if [ $CYRILLIC == 1 ]; then
        COMMENTS=$(echo "$COMMENTS" | iconv -f UTF8 -t CP1251)
    fi
    TRACK=$(dirname "$1")"/"$(basename "$1" .$EXT)
    for TAGID in $TAGLIST; do
        declare "TAG_$TAGID=$(echo "$COMMENTS" | grep -i ^"${TAGID}=" | awk -F "=" '{print $2}')"
        THIS="TAG_$TAGID"
        if [[ ${!THIS} != "" ]]; then
            LISTING+="$TAGID=${!THIS}"$'\n'
        fi
    done
    LISTING=$(echo "$LISTING" | sed -e 's/^$//g')
    eval $DECODE | oggenc -Q -q $QUALITY -o "$TRACK.new" -
    # Vorbiscomment decline other methods of processing parameters for me
    vorbiscomment -w "$TRACK.new" << EOF
$LISTING
EOF
    rm -f "$1"
    mv "$TRACK.new" "$TRACK.ogg"
}

# Read (if any) options from command line
export QUALITY=8
export CYRILLIC=0
while getopts "hiq:" opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        i)
            CYRILLIC=$((CYRILLIC+1))
            ;;
        q)
            QUALITY=$OPTARG
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done

if [ $CYRILLIC == 1 ]; then
    CYR_SUPPORT=`iconv -l | grep -c "CP1251"`
    if [ $CYR_SUPPORT = "0" ]; then echo "ICONV cannot convert to CP1251"; exit 1; fi
fi

export -f convert_file
MAXPROC=$(nproc)
find . -iname "*.ogg" -print0 -o -iname "*.flac" -print0 | \
  xargs -L 1 -P $MAXPROC -0 -I{} bash -c "convert_file \"{}\""
