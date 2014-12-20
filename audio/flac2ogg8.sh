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
Convert all files in current directory (recursively) from FLAC to Ogg Vorbis.
WARNING! Original files will be deleted!
    -h          display this help and exit
    -i          enable conversion to CP-1251 codepage
    -q          set quality of Ogg file (default = 8)
EOF
}

# Main function
convert_file() {
    # If script was triggered with -i parameter enable conversion
    echo "Converting file $1"
    if [ $CYRILLIC == 1 ]; then
        COMMENTS=$(metaflac --export-tags-to=- "$1" | iconv -f UTF8 -t CP1251)
    else
        COMMENTS=$(metaflac --export-tags-to=- "$1")
    fi
    TRACK=$(basename "$1" .flac)".ogg"
    for TAGID in $TAGLIST; do
        declare "TAG_$TAGID=$(echo "$COMMENTS" | grep -i ^"${TAGID}=" | awk -F "=" '{print $2}')"
        THIS="TAG_$TAGID"
        if [[ ${!THIS} != "" ]]; then
            LISTING+="$TAGID=${!THIS}"$'\n'
        fi
    done
    LISTING=$(echo "$LISTING" | sed -e 's/^$//g')
    flac -sdc "$1" | oggenc -Q -q $QUALITY -o "$TRACK" -
    # Vorbiscomment decline other methods of processing parameters for me
    vorbiscomment -w "$TRACK" << EOF
$LISTING
EOF
    rm -f "$1"
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
find . -iname "*.flac" -print0 | \
  xargs -L 1 -P $MAXPROC -0 -I{} bash -c "convert_file \"{}\""
