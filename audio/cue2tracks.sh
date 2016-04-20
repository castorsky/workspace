#!/bin/bash

PATH=${PATH}:/bin:/usr/bin:/usr/local/bin
export PATH=$PATH

# --== ERRORS ==--

chk_error=0

NO_ERR=0
E_UNK=1

E_TOOL_NOT_FOUND=2
E_UNK_OUT_CODEC=3
E_UNK_IN_CODEC=4
E_IN_FILE_NOT_FOUND=5

E_TOOL_CBP_NOT_FOUND=6
E_TOOL_CP_NOT_FOUND=7
E_TOOL_ST_NOT_FOUND=8
E_TOOL_F_NOT_FOUND=9
E_TOOL_IC_NOT_FOUND=10

E_TAG_APE_NOT_FOUND=11
E_TAG_FLAC_NOT_FOUND=12
E_TAG_MP3_NOT_FOUND=13
E_TAG_OGG_NOT_FOUND=14

E_CODEC_FLAC_NOT_FOUND=15
E_CODEC_FLAKE_NOT_FOUND=16
E_CODEC_APE_NOT_FOUND=17
E_CODEC_WVp_NOT_FOUND=18
E_CODEC_WVu_NOT_FOUND=19
E_CODEC_OFR_NOT_FOUND=20
E_CODEC_SHN_NOT_FOUND=21
E_CODEC_TTA_NOT_FOUND=22
E_CODEC_MP3_NOT_FOUND=23
E_CODEC_OGGd_NOT_FOUND=24
E_CODEC_OGGe_NOT_FOUND=25

E_UNK_CODEPAGE=26
E_CODEPAGE_NOT_SET=27
E_CANT_CONVERT_CUE=28

E_CANT_SPLIT=29
E_CANT_READ_CUE=30

E_CANT_TAG_FLAC=31
E_CANT_TAG_APE=32
E_CANT_TAG_MP3=33
E_CANT_TAG_OGG=34

E_CANT_MKDIR=35
E_CANT_MOVE_FILE=36

E_WRONG_NUM_TRACKS=37

E_NOT_CUE_FILE=38

E_CANT_FIX_CUE=39

E_TAG_M4A_NOT_FOUND=40
E_CODEC_M4Ae_NOT_FOUND=41
E_CODEC_M4Ad_NOT_FOUND=42
E_CANT_TAG_M4A=43

E_CODEC_FFMPEG_NOT_FOUND=44
E_CODEC_MPC_NOT_FOUND=45
E_CODEC_TAK_NOT_FOUND=46

E_TOOL_IM_NOT_FOUND=47
E_CANT_CONVERT_PICTURE=48

E_OPTERROR=65

# --== VARIABLES ==--

NO_ARGS=0

NAME="CUE 2 Tracks"
DESC="Tool for spliting audio CD image to tracks with cue sheet info."
VER="0.2.16"
AUTHOR="Sergey <sergey.dryabzhinsky@gmail.com> and other AUTHORS"

# (tool|tag|codec)_* - set to <file> if its exists, "" otherwise

MIN_SHNTOOL_VERSION=300

tool_BC=""
tool_CBP=""
tool_CP=""
tool_ST=""
tool_F=""
tool_IC=""
tool_IM=""

tag_APE=""
tag_FLAC=""
tag_MP3=""
tag_OGG=""
tag_M4A=""

codec_FLAC=""
codec_FLAKE=""
codec_APE=""
codec_WVp=""
codec_WVu=""
codec_OFR=""
codec_SHN=""
codec_TTA=""
codec_MPC=""
codec_TAK=""

codec_MP3=""
codec_OGGd=""
codec_OGGe=""
codec_M4Ae=""
codec_M4Ad=""

codec_IN=""
codec_OUT=""

# (tool|tag|codec)_*_needed - set to 1 if its needed, 0 otherwise

tool_BC_needed=1
tool_CBP_needed=1
tool_CP_needed=1
tool_ST_needed=1
tool_F_needed=1
tool_IC_needed=1
tool_IM_needed=0

tag_APE_needed=0
tag_FLAC_needed=0
tag_MP3_needed=0
tag_OGG_needed=0
tag_M4A_needed=0

codec_FLAC_needed=0
codec_FLAKE_needed=0
codec_APE_needed=0
codec_WVp_needed=0
codec_WVu_needed=0
codec_OFR_needed=0
codec_SHN_needed=0
codec_TTA_needed=0
codec_MP3_needed=0
codec_OGGd_needed=0
codec_OGGe_needed=0
codec_M4Ae_needed=0
codec_M4Ad_needed=0
codec_MPC_needed=0
codec_TAK_needed=0

cueFile=""
inFile=""
inFileDir=""
file_splitlog=""
file_splitlogwork=""
outCodec="flac"
toolCodec="flac"
outCodecLevel=0  # best
outCodecParam=""
outCodecQuality="4"
outCodecBitRate=128
outCodecMode="V"
outExt="flac"
inCodec=""
inCodecParam=""
inFile2WAV=0
inPicture=""
inPicQuality=95
inPicSize="600x600"
tempPicture=""

fromCP=""
locCP="ASCII"

outFormatStr="%N"
outFileName=""
tempDirName="."
scriptName=`basename "$0"`

logDebug=0
logFile=""
onlyTest=1
quiteMode=0
splitInTest=0

niceness=0

putTags=1

useColors=0
useXTitle=0

pre_ALBUM_DATE=""
pre_ALBUM_GENRE=""
pre_ALBUM_DISCID=""
pre_ALBUM_NUMBER=""
pre_ALBUM_COMMENT=""

tags_ALBUM_TITLE=""
tags_ALBUM_PERFORMER=""
tags_ALBUM_COMPOSER=""
tags_ALBUM_GENRE=""
tags_ALBUM_DATE=""
tags_ALBUM_TRACKS=0
tags_ALBUM_ZTRACKS=0
tags_ALBUM_DISCID=""
tags_ALBUM_NUMBER=""
tags_ALBUM_NUMBERS=""
tags_ALBUM_COMMENT=""
tags_TRACK_TITLE=""
tags_TRACK_PERFORMER=""
tags_TRACK_COMPOSER=""
tags_TRACK_GENRE=""
tags_TRACK_NUMBER=0
tags_TRACK_ZNUMBER=0

# --== COLORS ==--
color_default='\033[00m'
color_red='\033[01;31m'
color_green='\033[01;32m'
color_yellow='\033[01;33m'
color_magenta='\033[01;35m'
color_cyan='\033[01;36m'

# --== FUNCTIONS ==--
set_xterm_title() {
    [ ${useXTitle} -ne 0 ] && echo -ne "\033]0;${NAME} v${VER} -= $1 =- \007"
}

log_file() {
    if [ ! -z "$logFile" ]; then
        echo -e `date +"%F %T"`": $1" >> "$logFile"
    fi
}

log_debug() {
    if [ $logDebug -ne 0 ]; then
        [ ${quiteMode} -eq 0 ] && echo -e `date +"%F %T"`"[DEBUG]: $1"
        log_file "$1"
    fi
}

get_tool_log_file() {
    if [ ! -z "$logFile" ]; then
        echo "$logFile"
    else
        echo "/dev/null"
    fi
}

print_error() {
    echo -e "${color_red}Error${color_default}: $1" >&2
    log_file "Error: $1"
}

print_message() {
    if [[ "$1" == "-n" ]]
    then
	[ ${quiteMode} -eq 0 ] && echo -e -n "$2"
        log_file "$2"
    else
	[ ${quiteMode} -eq 0 ] && echo -e "$1"
        log_file "$1"
    fi
}

# function for checking existance of tools
checktool() {
    tool="$1"
    pk="$2"

    log_debug "checktool(): tool='$1' pk='$2'"

    print_message -n "\t${color_yellow}*${color_default} Checking for '${color_cyan}${tool}${color_default}'..."

    ctool=`which "${tool}" 2>/dev/null`
    if [ ! -n "${ctool}" ]
    then
	print_message "\t[${color_red}failed${color_default}]! Install '${pk}'!\n"
	return ${E_TOOL_NOT_FOUND}
    else
	print_message "\t[${color_green}ok${color_default}]"
    fi
}

gettool() {
    tool="$1"

    ctool=`which "${tool}" 2>/dev/null`
    if [ ! -n "${ctool}" ]
    then
        log_debug "gettool(): tool='$1' not found"
	return ${E_TOOL_NOT_FOUND}
    else
	echo "${ctool}"
    fi
}

# check shntool version
check_shntool_version() {

    log_debug "check_shntool_version()"

    print_message -n "\t${color_yellow}*${color_default} Checking '${color_cyan}shntool${color_default}' version..."
    ver=`shntool -v 2>&1 | grep shntool | awk '{print $2}'`
    ver_clean=`echo ${ver} | sed -e 's:\.::g'`
    if ((${ver_clean}>=${MIN_SHNTOOL_VERSION}))
    then
	print_message "\t[${color_green}${ver}${color_default}]"
	return 0
    else
	print_message "\t[${color_red}${ver}${color_default}]! Install version 3.0 or higher!\n"
	return 1
    fi
}

# function for printing codecs
print_codecs() {
    echo -e "\tCodecs may be:\n\
\t\twav   : no encode, raw sound wave,\n\
\t\tflac  : (default) Free Lossless Audio Codec,\n\
\t\tflake : FLAC realisation via FFmpeg (beta),\n\
\t\tape   : Monkey's Audio Codec,\n\
\t\twv    : WavPack,\n\
\t\tofr   : OptimFrog,\n\
\t\tshn   : shorten,\n\
\t\tmp3   : mpeg 1 layer 3 via lame,\n\
\t\togg   : ogg vorbis\n\
\t\tm4a   : aac with m4a container,\n\
\t\tmpc   : MusePack,\n\
\t\ttak   : Tom's lossless Audio Kompressor,\n\
" >&2
}

# function for printing levels
print_levels() {
    echo -e "\tLevels may be:\n\
\t\t'best' or 0 : Best for store (default),\n\
\t\t'fast' or 1 : Fastest processing,\n\
\t\t'mid'  or 2 : Fairly good for portable hardware\n\
" >&2
}

# function for printing naming scheme
print_naming_scheme() {
    echo -e "\tNaming scheme is:\n\
\t\t%A : Album title\n\
\t\t%a : Album disc number\n\
\t\t%P : Album performer\n\
\t\t%D : Album date\n\
\t\t%G : Album genre\n\
\t\t%t : Track title\n\
\t\t%p : Track performer\n\
\t\t%g : Track genre\n\
\t\t%n : Track number\n\
\t\t%N : Track number with leading zero\n\
" >&2
}

# function for print some program info
print_info() {
    echo -e "\n${color_yellow}${NAME}, ${DESC}${color_default}\n\tVersion: ${color_cyan}${VER}${color_default}\n\tAuthor : ${color_cyan}${AUTHOR}${color_default}\n" >&2
}

# function for printing some help info
print_help() {
    print_info
    echo -e "\
Usage: ${scriptName} [options] <cue file>\n\
Options:\n\
\t-R              : Disable testing and doing nothing - starts Real work\n\
\t-C              : Use colored messages\n\
\t-X              : Set XTerm title\n\
\t-W              : Force recode to WAV before split. Make image.{codec}.wav\n\
\t-e              : Switch to debug mode\n\
\t-L <log file>   : Set log file. By default - none.\n\
\t-i <image file> : Set CD image file. If not set - read from cue\n\
\t-c <codec>      : Set output codec" >&2
    print_codecs
    echo -e "\
\t-l <level> : Set level of output codec compression rate.\
" >&2
    print_levels
    echo -e "\
\t-f <codepage>      : Convert to UTF-8 from this 'codepage'\n\
\t-d                 : Disable taging of output files with cue info\n\
\t-A <album>         : Set album title\n\
\t-P <performer>     : Set album performer\n\
\t-K <composer>      : Set album composer\n\
\t-D <date>          : Set album date\n\
\t-G <genre>         : Set album genre\n\
\t-I <id>            : Set album disk ID\n\
\t-N <number>        : Set album disc number\n\
\t-O <comment>       : Set album comment\n\
\n\
\tCover art picture options:\n\
\t-p <picture>       : Set album cover picture.\n\
\t                     If not set - try to read from FLAC image file.\n\
\tExternal pictures conversion only:\n\
\t-j <quality>       : Set JPEG picture quality (95 - default).\n\
\t                     0 - low, 100 - high\n\
\t-r <width>x<height>: Set output picture size (600x600 - default).\n\
\t                     For larger pictures only.\n\
\n\
\t-o <format string> : Set naming scheme for output files\
" >&2
    print_naming_scheme
    echo -e "\
\t-V         : Print version and exit\n\
\t-h         : Print this help and exit\n\
\t-q         : Quite mode - only errors to stderr\n\
\t-s         : Start spliting even in testing mode (to /dev/null)\n\
\t-n <level> : Nice level (process scheduling priority):\n\
\t             From high (-19) to low (19)\n\
\n\
\tOptions only for mp3, ogg, mpc:\n\
\t-Q <quality> : Set quality of codec compression (4 - default)\n\
\tQuality may be:\n\
\t\tMP3 :   0 - high,  9 - low\n\
\t\tM4A : 500 - high, 10 - low\n\
\t\tOGG :  10 - high, -1 - low\n\
\t-B <bitrate>      : Set compression bitrate in kbps (default to 'high')\n\
\t-M <bitrate mode> : C - Constant, V - Variable (default)\n\
\t\tNote: If choosen V - then -B specifies maximum bitrate (only mp3)\n\
\n\
To get some action run:\n\
\t${scriptName} -c flac -f cp1251 -o \"/path/to/music/%P/%D - %A/%N\" CDimage.cue\n\
" >&2
}

# function for print program version
print_version() {
    echo "${VER}"
}

# function for checking output codecs
check_outCodec() {

    log_debug "check_outCodec()"

    [ ! -n "${outCodec}" ] && outCodec="flac"

    outCodec=`echo ${outCodec} | tr [:upper:] [:lower:]`

    case "${outCodec}" in
	"flac" )
	    codec_FLAC_needed=1
	    if [ ${putTags} -eq 1 ]; then tag_FLAC_needed=1; fi
	    outExt="flac"
	    toolCodec="${outCodec}"
	    outCodecParam=" flac -8 -o %f -"
	    [ ${outCodecLevel} -eq 1 ] && outCodecParam=" flac -1 -o %f -"
	    [ ${outCodecLevel} -eq 2 ] && outCodecParam=" flac -4 -o %f -"
	    codec_OUT="flac"
	;;
	"flake" )
	    codec_FLAKE_needed=1
	    if [ ${putTags} -eq 1 ]; then tag_FLAC_needed=1; fi
	    outExt="flac"
	    toolCodec="${outExt}"
	    outCodecParam=" flake -12 - %f"
	    [ ${outCodecLevel} -eq 1 ] && outCodecParam=" flake -1 - %f"
	    [ ${outCodecLevel} -eq 2 ] && outCodecParam=" flake -4 - %f"
	    codec_OUT="flake"
	;;
	"tak" )
	    codec_TAK_needed=1
	    if [ ${putTags} -eq 1 ]; then tag_APE_needed=1; fi
	    outExt="tak"
	    toolCodec="${outCodec}"
	    outCodecParam=" takc -e -v -pMax -md5 -silent -overwrite - %f"
	    [ ${outCodecLevel} -eq 1 ] && outCodecParam=" takc -e -v -md5 -silent -overwrite - %f"
	    codec_OUT="takc"
	;;
	"ape" )
	    codec_APE_needed=1
	    if [ ${putTags} -eq 1 ]; then tag_APE_needed=1; fi
	    outExt="ape"
	    toolCodec="${outCodec}"
	    outCodecParam=" mac - %f -c5000"
	    [ ${outCodecLevel} -eq 1 ] && outCodecParam=" mac - %f -c1000"
	    [ ${outCodecLevel} -eq 2 ] && outCodecParam=" mac - %f -c3000"
	    codec_OUT="mac"
	;;
	"wv" )
	    codec_WVp_needed=1
	    if [ ${putTags} -eq 1 ]; then tag_APE_needed=1; fi
	    outExt="wv"
	    toolCodec="${outCodec}"
	    outCodecParam=" wavpack -hh -x6 - -o %f"
	    [ ${outCodecLevel} -eq 1 ] && outCodecParam=" wavpack -f - -o %f"
	    [ ${outCodecLevel} -eq 2 ] && outCodecParam=" wavpack -h - -o %f"
	    codec_OUT="wavpack"
	;;
	"ofr" )
	    codec_OFR_needed=1
	    toolCodec="${outCodec}"
	    outExt="ofr"
	    codec_OUT="optimfrog"
	;;
	"shn" )
	    codec_SHN_needed=1
	    toolCodec="${outCodec}"
	    outExt="shn"
	    codec_OUT="shorten"
	;;
	"mpc" )
	    codec_MPC_needed=1
	    if [ ${putTags} -eq 1 ]; then tag_APE_needed=1; fi
	    toolCodec="cust"
	    outExt="mpc"
	    codec_OUT="mpcenc"
            outCodecParam=" ext=mpc mpcenc --silent --overwrite --quality ${outCodecQuality} - %f"
	;;
	"mp3" )
	    codec_MP3_needed=1
	    if [ ${putTags} -eq 1 ]; then tag_MP3_needed=1; fi
	    outExt="mp3"
	    toolCodec="cust"
	    outCodecParam=" ext=mp3 lame -S -m j -q ${outCodecQuality}"
	    if [ "${outCodecMode}" = "C" ]
	    then
		outCodecParam=" ${outCodecParam} --cbr -b ${outCodecBitRate}"
	    else
		outCodecParam=" ${outCodecParam} -v --vbr-new -B ${outCodecBitRate} -V ${outCodecQuality}"
	    fi
	    outCodecParam=" ${outCodecParam} - %f"
	    codec_OUT="lame"
	;;
	"m4a" )
	    codec_M4Ae_needed=1
	    if [ ${putTags} -eq 1 ]; then tag_M4A_needed=1; fi
	    outExt="m4a"
	    toolCodec="cust"
	    outCodecParam=" ext=m4a faac"
	    if [ "${outCodecMode}" = "C" ]
	    then
		outCodecParam=" ${outCodecParam} -b ${outCodecBitRate}"
	    else
		outCodecParam=" ${outCodecParam} -q ${outCodecQuality}"
	    fi
	    outCodecParam=" ${outCodecParam} -w - -o %f"
	    codec_OUT="faac"
	;;
	"ogg" )
	    codec_OGGe_needed=1
	    if [ ${putTags} -eq 1 ]; then tag_OGG_needed=1; fi
	    outExt="ogg"
	    toolCodec="cust"
	    outCodecParam=" ext=ogg oggenc -Q"
	    if [ "${outCodecMode}" = "C" ]
	    then
		outCodecParam=" ${outCodecParam} -b ${outCodecBitRate}"
	    else
		outCodecParam=" ${outCodecParam} -q ${outCodecQuality}"
	    fi
	    outCodecParam=" ${outCodecParam} -o %f -"
	    codec_OUT="oggenc"
	;;
	"wav" )
	    outExt="wav"
	    toolCodec="wav"
	    putTags=0
	;;
	* )
	    print_error "Output codec '${color_cyan}${outCodec}${color_default}' not supported."
	    [ ${quiteMode} -eq 0 ] && print_codecs
	    return ${E_UNK_OUT_CODEC}
	;;
    esac
    print_message "\tSetting output codec to '${color_cyan}${outCodec}${color_default}'"
}

check_inCodec() {

    log_debug "check_inCodec()"

    [ ! -n "${inFile}" ] && inFile=`grep -m 1 FILE "${cueFile}" | sed -r 's/(.?*)\"(.?*)\"(.?*)/\2/g'`

    print_message "\tFile to split: '${color_cyan}${inFileDir}/${inFile}${color_default}'"

    if [ ! -e "${inFileDir}/${inFile}" ]
    then
	print_error "\tFile '${color_cyan}${inFileDir}/${inFile}${color_default}' not found, trying other extensions..."
        inFileBase="${inFile%.*}"
        extFound=""
        for ext in flac ape wv ofr shn tta mp3 m4a ogg wav
        do
            if [ -e "${inFileDir}/${inFileBase}.${ext}" -o -e "${inFileDir}/${inFileBase}.${ext^^}" ]; then
                print_message "\tFound: ${inFileDir}/${inFileBase}.${ext}"
                extFound=${ext}
                break
            fi
        done
        if [ -z "$extFound" ]; then
            print_error "Neither file '${color_cyan}${inFileDir}/${inFile}${color_default}' not found, nor similar with another extension!"
            [ ${onlyTest} -eq 0 ] && return ${E_IN_FILE_NOT_FOUND}
        else
            inFile="${inFileBase}.${extFound}"
        fi
    fi

    inCodec="${inFile##*.}"
    inCodec=`echo ${inCodec} | tr [:upper:] [:lower:]`

    case "${inCodec}" in
	"flac" )
	    codec_FLAC_needed=1
                        [ -z "${inPicture}" ] && tag_FLAC_needed=1
	    codec_IN="flac"
	;;
	"ape" )
	    codec_APE_needed=1
	    codec_IN="mac"
	;;
	"wv" )
	    codec_WVu_needed=1
	    codec_IN="wvunpack"
	;;
	"ofr" )
	    codec_OFR_needed=1
	    codec_IN="optimfrog"
	;;
	"shn" )
	    codec_SHN_needed=1
	    codec_IN="shorten"
	;;
	"tta" )
	    codec_TTA_needed=1
	    codec_IN="ttaenc"
	;;
	"mp3" )
	    codec_MP3_needed=1
	    codec_IN="wav"
	    inFile2WAV=1
	;;
	"m4a" )
	    codec_M4Ad_needed=1
	    codec_IN="wav"
	    inFile2WAV=1
	;;
	"ogg" )
	    codec_OGGe_needed=1
	    codec_IN="wav"
	    inFile2WAV=1
	;;
	"wav" )
	;;
	* )
	    print_error "Input codec '${color_cyan}${inCodec}${color_default}' not supported."
	    return ${E_UNK_IN_CODEC}
	;;
    esac
    print_message "\tSetting input codec to '${color_default}${inCodec}${color_default}'"
}

# function for search tools
search_tools() {

    log_debug "search_tools()"

    if [ ${tool_BC_needed} -eq 1 ]
    then
	checktool bc bc
	tool_BC=`gettool bc`
	[ -n "${tool_BC}" ] || return ${E_TOOL_NOT_FOUND}
    fi

    if [ ${tool_CBP_needed} -eq 1 ]
    then
	checktool cuebreakpoints cuetools
	tool_CBP=`gettool cuebreakpoints`
	[ -n "${tool_CBP}" ] || return ${E_TOOL_CBP_NOT_FOUND}
    fi

    if [ ${tool_CP_needed} -eq 1 ]
    then
	checktool cueprint cuetools
	tool_CP=`gettool cueprint`
	[ -n "${tool_CP}" ] || return ${E_TOOL_CP_NOT_FOUND}
    fi

    if [ ${tool_ST_needed} -eq 1 ]
    then
	checktool shntool shntool
	tool_ST=`gettool shntool`
	[ -n "${tool_ST}" ] || return ${E_TOOL_ST_NOT_FOUND}
	check_shntool_version || return ${E_TOOL_ST_NOT_FOUND}
    fi

    if [ ${tool_F_needed} -eq 1 ]
    then
	checktool file file
	tool_F=`gettool file`
	[ -n "${tool_F}" ] || return ${E_TOOL_F_NOT_FOUND}
    fi

    if [ ${tool_IC_needed} -eq 1 ]
    then
	checktool iconv glibc
	tool_IC=`gettool iconv`
	[ -n "${tool_IC}" ] || return ${E_TOOL_IC_NOT_FOUND}
    fi

    if [ ${tool_IM_needed} -eq 1 ]
    then
	checktool convert imagemagick
	tool_IM=`gettool convert`
	[ -n "${tool_IM}" ] || return ${E_TOOL_IM_NOT_FOUND}
    fi
}

# function for searching (de|en)coders
search_dencoders() {

    log_debug "search_dencoders()"

    if [ ${codec_WVp_needed} -eq 1 ]
    then
	checktool wavpack wavpack
	codec_WVp=`gettool wavpack`
	[ -n "${codec_WVp}" ] || return ${E_CODEC_WVp_NOT_FOUND}
    fi

    if [ ${codec_WVu_needed} -eq 1 ]
    then
	checktool wvunpack wavpack
	codec_WVu=`gettool wvunpack`
	[ -n "${codec_WVu}" ] || return ${E_CODEC_WVu_NOT_FOUND}
    fi

    if [ ${codec_SHN_needed} -eq 1 ]
    then
	checktool shorten shorten
	codec_SHN=`gettool shorten`
	[ -n "${codec_SHN}" ] || return ${E_CODEC_SHN_NOT_FOUND}
    fi

    if [ ${codec_APE_needed} -eq 1 ]
    then
	checktool mac mac
	codec_APE=`gettool mac`
	if [ ! -n "${codec_APE}" ]; then
            if [ "${inCodec}" = "ape" ]; then
                checktool ffmpeg ffmpeg
                codec_APE=`gettool ffmpeg`
	        if [ -n "${codec_APE}" ]; then
                    inCodec="ape_ffmpeg"
                    codec_IN="wav"
                    inFile2WAV=1
	            print_message "\tSwitching to ${color_yellow}FFMPEG${color_default}, and recode input file to ${color_yellow}WAV${color_default}..."
                else
                    return ${E_CODEC_FFMPEG_NOT_FOUND}
                fi
            else
                return ${E_CODEC_APE_NOT_FOUND}
            fi
        fi
    fi

    if [ ${codec_FLAC_needed} -eq 1 ]
    then
	checktool flac flac
	codec_FLAC=`gettool flac`
	[ -n "${codec_FLAC}" ] || return ${E_CODEC_FLAC_NOT_FOUND}
    fi

    if [ ${codec_FLAKE_needed} -eq 1 ]
    then
	checktool flake flake
	codec_FLAKE=`gettool flake`
	[ -n "${codec_FLAKE}" ] || return ${E_CODEC_FLAKE_NOT_FOUND}
    fi

    if [ ${codec_OFR_needed} -eq 1 ]
    then
	checktool ofr optimfrog
	codec_OFR=`gettool ofr`
	[ -n "${codec_OFR}" ] || return ${E_CODEC_OFR_NOT_FOUND}
    fi

    if [ ${codec_TTA_needed} -eq 1 ]
    then
	checktool ttaenc ttaenc
	codec_TTA=`gettool ttaenc`
	[ -n "${codec_TTA}" ] || return ${E_CODEC_TTA_NOT_FOUND}
    fi

    if [ ${codec_MP3_needed} -eq 1 ]
    then
	checktool lame lame
	codec_MP3=`gettool lame`
	[ -n "${codec_MP3}" ] || return ${E_CODEC_MP3_NOT_FOUND}
    fi

    if [ ${codec_M4Ae_needed} -eq 1 ]
    then
	checktool faac faac
	codec_M4Ae=`gettool faac`
	[ -n "${codec_M4Ae}" ] || return ${E_CODEC_M4Ae_NOT_FOUND}
    fi

    if [ ${codec_M4Ad_needed} -eq 1 ]
    then
	checktool faad faad
	codec_M4Ad=`gettool faad`
	[ -n "${codec_M4Ad}" ] || return ${E_CODEC_M4Ad_NOT_FOUND}
    fi

    if [ ${codec_OGGd_needed} -eq 1 ]
    then
	checktool oggdec oggdec
	codec_OGGd=`gettool oggdec`
	[ -n "${codec_OGGd}" ] || return ${E_CODEC_OGGd_NOT_FOUND}
    fi

    if [ ${codec_OGGe_needed} -eq 1 ]
    then
	checktool oggenc oggenc
	codec_OGGe=`gettool oggenc`
	[ -n "${codec_OGGe}" ] || return ${E_CODEC_OGGe_NOT_FOUND}
    fi

     if [ ${codec_MPC_needed} -eq 1 ]
     then
         checktool mpcenc musepack-tools
         codec_MPC=`gettool mpcenc`
         [ -n "${codec_MPC}" ] || return ${E_CODEC_MPC_NOT_FOUND}
     fi

     if [ ${codec_TAK_needed} -eq 1 ]
     then
         checktool takc tak
         codec_TAK=`gettool takc`
         [ -n "${codec_TAK}" ] || return ${E_CODEC_TAK_NOT_FOUND}
     fi
}

# function for search taging tools
search_tagers() {

    log_debug "search_tagers()"

    if [ ${tag_APE_needed} -eq 1 ]
    then
	checktool apetag apetag
	tag_APE=`gettool apetag`
	[ -n "${tag_APE}" ] || return ${E_TAG_APE_NOT_FOUND}
    fi

    if [ ${tag_FLAC_needed} -eq 1 ]
    then
	checktool metaflac flac
	tag_FLAC=`gettool metaflac`
	[ -n "${tag_FLAC}" ] || return ${E_TAG_FLAC_NOT_FOUND}
    fi

    if [ ${tag_MP3_needed} -eq 1 ]
    then
	checktool eyeD3 python-eyed3
	tag_MP3=`gettool eyeD3`
	[ -n "${tag_MP3}" ] || return ${E_TAG_MP3_NOT_FOUND}
    fi

    if [ ${tag_M4A_needed} -eq 1 ]
    then
	checktool mp4tags mpeg4ip-utils
	tag_M4A=`gettool mp4tags`
	[ -n "${tag_M4A}" ] || return ${E_TAG_M4A_NOT_FOUND}
    fi

    if [ ${tag_OGG_needed} -eq 1 ]
    then
	checktool vorbiscomment vorbis-tools
	tag_OGG=`gettool vorbiscomment`
	[ -n "${tag_OGG}" ] || return ${E_TAG_OGG_NOT_FOUND}
    fi
}

#function for trying codepage
try_codepage() {
    tcp=$1

    log_debug "try_codepage(): tcp='$1'"

    if [ -n "${tcp}" ]
    then
	trycdp=`${tool_IC} -l | grep -i "${tcp}"`
	if [ ! -n "$trycdp" ]
	then
	    print_error "Unknown codepage: '${color_cyan}${tcp}${color_default}..."
	    return ${E_UNK_CODEPAGE}
	fi
    else
	return ${E_CODEPAGE_NOT_SET}
    fi
}

# function for geting ocale codepage
get_local_codepage() {
    if [ -n "${LANG}" ]
    then
	locCP=`echo ${LANG} | sed -r 's/(.?*)\.(.?*)/\2/g'`
	[ ! -n "${locCP}" ] && locCP="ASCII"
    else
	locCP="ASCII"
    fi

    log_debug "get_local_codepage(): locCP='$locCP'"
}

# Check for BOM simbol
is_file_unicode() {

    log_debug "is_file_unicode()"

    [ ! -f "$1" ] && return -1
    bom=`head -c 3 "$1"`
    [ ${bom} = $'\357\273\277' ] && return 1
    return 0
}

prepare_and_fix_cue() {

    log_debug "prepare_and_fix_cue()"

    is_file_unicode "${cueFile}"
    # Remove BOM record?
    if [ $? -eq 1 ]
    then
	print_message "\t${color_yellow}Fix${color_default}: Now we try to remove BOM record..."
	bnc=`basename "${cueFile}" .cue`
	ncn="${tempDirName}/${bnc}.nobom.cue"
	symbols=`cat "${cueFile}" | wc -c`
	((symbols-=3))
	tail -c ${symbols} "${cueFile}" > "${ncn}"
	[ $? -ne 0 ] && return ${E_CANT_FIX_CUE}
	cueFile="${ncn}"
	print_message "\tNew cue sheet file name: '${color_cyan}${cueFile}${color_default}'"
    fi
    lastline=`tail -n 1 "${cueFile}" | tr -d [:blank:] | tr -d [:cntrl:]`
    if [[ "${lastline}" != "" ]]
    then
	print_message "\t${color_yellow}Fix${color_default}: Last empty line missing..."
	bnc=`basename "${cueFile}" .cue`
	ncn="${tempDirName}/${bnc}.line.cue"
	cp "${cueFile}" "${ncn}"
        # Try to fix copied permissions @9
        chmod 644 "${ncn}"
	echo -e "\n" >> "${ncn}"
	[ $? -ne 0 ] && return ${E_CANT_FIX_CUE}
	cueFile="${ncn}"
	print_message "\tNew cue sheet file name: '${color_cyan}${cueFile}${color_default}'"
    fi
}

# function for recode cue sheet file
recode_cue() {

    log_debug "recode_cue()"

    isutf=""
    if [ -n "${tool_F}" ]
    then
	isutf=`${tool_F} "${cueFile}" | grep "UTF-8"`
    else
	isutf=""
    fi

    isascii=""
    if [ -n "${tool_F}" ]
    then
	isascii=`${tool_F} "${cueFile}" | grep "ASCII"`
    else
	isascii=""
    fi

    if [ -n "${isutf}" ]
    then
	print_message "\tSeems like cue sheet already in UTF-8 encoding. ${color_green}Good${color_default}! ;)"
    else
	if [ -n "${isascii}" ]
	then
	    print_message "\tSeems like cue sheet in ASCII encoding. ${color_yellow}Not bad${color_default}... :|"
	    [ ! -n "${fromCP}" ] && return 0
	else
	    print_message "\tSeems like cue sheet not in UTF-8 encoding. ${color_red}Bad${color_default}! :("
	fi

	if [ -n "${tool_IC}" ]
	then
	    if [ -n "${fromCP}" ]
	    then
		get_local_codepage

		chk_error=0
		try_codepage ${fromCP}
		chk_error=$?
		[ ${chk_error} -ne 0 ] && fromCP=${locCP}

		print_message "\tNow we try to recode cue sheet to ${color_green}UTF-8${color_default} from ${color_yellow}${fromCP}${color_default}..."
		bnc=`basename "${cueFile}" .cue`
		cat "${cueFile}" | ${tool_IC} -f "${fromCP}" -t "UTF-8" > "${tempDirName}/${bnc}.utf8.cue"
		[ $? -ne 0 ] && return ${E_CANT_CONVERT_CUE}
		cueFile="${tempDirName}/${bnc}.utf8.cue"
		print_message "\tNew cue sheet file name: '${color_cyan}${cueFile}${color_default}'"
	    fi
	fi
    fi
}

recode_to_wav() {

    log_debug "recode_to_wav()"

    inFileWAV="${inFile}.wav"
    [ ${onlyTest} -ne 0 ] && return
    errors=0
    FullPathIN="${inFileDir}/${inFile}"
    FullPathOUT="${tempDirName}/${inFileWAV}"
    print_message "\tRecoding '${color_cyan}${inFile}${color_default}' to WAV..."
    case "${inCodec}" in
	"flac" )
	    ${codec_FLAC} -d -f -o "${FullPathOUT}" "${FullPathIN}"
	    errors=$?
	;;
	"flac_ffmpeg" )
	    ffmpeg -i "${FullPathIN}" "${FullPathOUT}"
	    errors=$?
	;;
	"ape" )
	    mac "${FullPathIN}" "${FullPathOUT}" -d
	    errors=$?
	;;
	"ape_ffmpeg" )
	    ffmpeg -i "${FullPathIN}" "${FullPathOUT}"
	    errors=$?
	;;
	"wv" )
	    wvunpack -y -o "${FullPathOUT}" "${FullPathIN}"
	    errors=$?
	;;
	"wv_ffmpeg" )
	    ffmpeg -i "${FullPathIN}" "${FullPathOUT}"
	    errors=$?
	;;
	"ofr" )
	    ffmpeg -i "${FullPathIN}" "${FullPathOUT}"
	    errors=$?
	;;
	"shn" )
	    shorten -x "${FullPathIN}" "${FullPathOUT}"
	    errors=$?
	;;
	"shn_ffmpeg" )
	    ffmpeg -i "${FullPathIN}" "${FullPathOUT}"
	    errors=$?
	;;
	"tta" )
	    ttaenc -d -o "${FullPathOUT}" "${FullPathIN}"
	    errors=$?
	;;
	"tta_ffmpeg" )
	    ffmpeg -i "${FullPathIN}" "${FullPathOUT}"
	    errors=$?
	;;
	"mp3" )
	    lame -S --decode "${FullPathIN}" "${FullPathOUT}"
	    errors=$?
	;;
	"mp3_ffmpeg" )
	    ffmpeg -i "${FullPathIN}" "${FullPathOUT}"
	    errors=$?
	;;
	"m4a" )
	    faad -q -o "${FullPathOUT}" "${FullPathIN}"
	    errors=$?
	;;
	"m4a_ffmpeg" )
	    ffmpeg -i "${FullPathIN}" "${FullPathOUT}"
	    errors=$?
	;;
	"ogg" )
	    oggdec -Q --decode -o "${FullPathOUT}" "${FullPathIN}"
	    errors=$?
	;;
	"ogg_ffmpeg" )
	    ffmpeg -i "${FullPathIN}" "${FullPathOUT}"
	    errors=$?
	;;
	"wav" )
	;;
	* )
	    print_error "Decode '${color_cyan}${inCodec}${color_default}' to WAV not supported."
	    return ${E_UNK_IN_CODEC}
	;;
    esac
    [ ${errors} -ne 0 ] && return -1
    inFile="${inFileWAV}"
    inFileDir="${tempDirName}"
    inCodec="wav"
    codec_IN="wav"
    print_message "\tSetting new input file to '${color_cyan}${inFile}${color_default}'"
}

# function for split condition
split_cond() {
    tlc=$1
    ttl="$2"
    (( tlc < totalTracks )) && return 0
    [ ! -n "${ttl}" ] && return 0
    return 1
}

# function for image splitting
split_image() {

    log_debug "split_image()"

    runopt=""
    [ ${quiteMode} -ne 0 ] && runopt="-q"
    file_splitlog="${tempDirName}/split.log"
    file_splitlogwork="${file_splitlog}.work"
    err=0
    splitGapsFirst=""
    prependGapsFirst=""
    _outCodecOpts=""
    if [ ${onlyTest} -eq 0 ]
    then
	_outCodecOpts="${toolCodec}${outCodecParam}"
    else
	[ ${splitInTest} -eq 0 ] && return 0
	_outCodecOpts="null"
    fi

    cd "${inFileDir}"

    splitGapsFirst=$(${tool_CBP} --split-gaps "${cueFile}" | head -1)
    prependGapsFirst=$(${tool_CBP} --prepend-gaps "${cueFile}" | head -1)
    if [ "${splitGapsFirst}" == "${prependGapsFirst}" ]
    then
	totalTracks=${tags_ALBUM_TRACKS}
	${tool_CBP} "${cueFile}" | ${tool_ST} split ${runopt} -d "${tempDirName}" -O always -t %n ${inCodecParam} -o "${_outCodecOpts}" "./${inFile}" &> "${file_splitlog}" &
    else
	print_message "\tFirst track pregap found!"
	totalTracks=$((${tags_ALBUM_TRACKS} + 1))
	echo -e "${splitGapsFirst}\n$(${tool_CBP} "${cueFile}")" | ${tool_ST} split ${runopt} -d "${tempDirName}" -O always -t %n ${inCodecParam} -o "${_outCodecOpts}" "./${inFile}" &> "${file_splitlog}" &
    fi
    disown %1
    cd "${OLDPWD}"

    lc=0
    tl=""
    cl=""
    llc=${lc}
    lw=0
    split_cond ${lc} "${tl}"
    sc=$?
    while [ ${sc} -eq 0 ]
    do
	if [ -e "${file_splitlog}" ]
	then
	    cp "${file_splitlog}" "${file_splitlogwork}"
	    cl=`tail -n 1 "${file_splitlogwork}" | awk 'BEGIN {FS="\b\b\b\b\b"} { if ( NF > 1 ) print $1, $NF; else print $1}' | sed -e 's/\ \ 0%\ \ //g' -e 's/Splitting\ //g'`
	    if [ -n "${cl}" ]
	    then
		llc=${lc}
		lc=`cat "${file_splitlogwork}" | wc -l`
		((lc++))
		spl=`echo ${cl} | tr -d [:cntrl:] | awk 'BEGIN {FS=" : "} {print $1}' | sed -e "s:${tempDirName}/::g" -e "s:\./::g"`
		prc=`echo ${cl} | awk 'BEGIN {FS=" : "} {print $2}'`
		if (( lc <= totalTracks ))
		then
		    bs="\b"
		    for ((i=1;i<lw;i++))
		    do
			bs="${bs}\b"
		    done

		    if (( llc != lc ))
		    then
			if (( lc > 1 ))
			then
			    print_message "${bs}${color_green}100%${color_default}"
			else
			    print_message ""
			fi
			print_message -n "Track ${color_green}${lc}${color_default}: ${spl} : ${color_yellow}${prc}${color_default}"
			lw=${#prc}
		    else
			print_message -n "${bs}${color_yellow}${prc}${color_default}"
			lw=${#prc}
		    fi
		    set_xterm_title "Splitting Track ${lc} of ${totalTracks}, Progress: ${prc}"
		else
		    print_message "${bs}${color_green}100%${color_default}"
		fi
	    fi
	    tl=`echo "${cl}" | grep "100% OK"`
	    split_cond ${lc} "${tl}"
	    sc=$?
	fi
	str=`ps ax | grep shntool | grep -v grep`
	if [[ "${str}" == "" ]]
	then
	    if [ ${sc} -eq 0 ]
	    then
#				err=1
		sc=1
	    fi
	fi
	sleep 1s
    done

    if [ ${err} -ne 0 ]
    then
	print_error "Some error occured while spliting file '${color_cyan}${inFileDir}/${inFile}${color_default}'!"
	return ${E_CANT_SPLIT}
    fi
}

# function for image splitting (debug version), just output everything
split_image_debug() {

    log_debug "split_image_debug()"

    runopt=""
    [ ${quiteMode} -ne 0 ] && runopt="-q"
    file_splitlog="${tempDirName}/split.log"
    file_splitlogwork="${file_splitlog}.work"
    err=0
    _outCodecOpts=""
    if [ ${onlyTest} -eq 0 ]
    then
	_outCodecOpts="${toolCodec}${outCodecParam}"
    else
	[ ${splitInTest} -eq 0 ] && return 0
	_outCodecOpts="null"
    fi

    log=`get_tool_log_file`

    cd "${inFileDir}"

    splitGapsFirst=$(${tool_CBP} --split-gaps "${cueFile}" | head -1)
    prependGapsFirst=$(${tool_CBP} --prepend-gaps "${cueFile}" | head -1)
    if [ "${splitGapsFirst}" == "${prependGapsFirst}" ]
    then
	totalTracks=${tags_ALBUM_TRACKS}
	${tool_CBP} "${cueFile}" | ${tool_ST} split ${runopt} -d "${tempDirName}" -O always -t %n ${inCodecParam} -o "${_outCodecOpts}" "./${inFile}" 2>&1 | tee -a "$log"
	err=$?
    else
	print_message "\tFirst track pregap found!"
	totalTracks=$((${tags_ALBUM_TRACKS} + 1))
	echo -e "${splitGapsFirst}\n$(${tool_CBP} "${cueFile}")" | ${tool_ST} split ${runopt} -d "${tempDirName}" -O always -t %n ${inCodecParam} -o "${_outCodecOpts}" "./${inFile}" 2>&1 | tee -a "$log"
	err=$?
    fi

    cd "${OLDPWD}"

    if [ ${err} -ne 0 ]
    then
	print_error "Some error occured while spliting file '${color_cyan}${inFileDir}/${inFile}${color_default}'!"
	return ${E_CANT_SPLIT}
    fi
}

# function for reading album info
read_album_info() {

    log_debug "read_album_info(): tool_CP=${tool_CP}; cueFile=${cueFile}"

    test=`${tool_CP} -d %N "${cueFile}" 2>&1 | grep error`
    if [ -n "${test}" ]
    then
	print_error "Some error occured while reading CUE sheet!"
	return ${E_CANT_READ_CUE}
    fi

    if [ ! -n "${pre_ALBUM_PERFORMER}" ]
    then
	tags_ALBUM_PERFORMER=`${tool_CP} -d %P "${cueFile}"`
    else
	tags_ALBUM_PERFORMER="${pre_ALBUM_PERFORMER}"
    fi
    print_message "\tAlbum Performer = ${color_cyan}${tags_ALBUM_PERFORMER}${color_default}"

    if [ ! -n "${pre_ALBUM_COMPOSER}" ]
    then
	tags_ALBUM_COMPOSER=`${tool_CP} -d %C "${cueFile}"`
    else
	tags_ALBUM_COMPOSER="${pre_ALBUM_COMPOSER}"
    fi
    [ -n "${tags_ALBUM_COMPOSER}" ] && print_message "\tAlbum Performer = ${color_cyan}${tags_ALBUM_PERFORMER}${color_default}"

    if [ ! -n "${pre_ALBUM_TITLE}" ]
    then
	tags_ALBUM_TITLE=`${tool_CP} -d %T "${cueFile}"`
    else
	tags_ALBUM_TITLE="${pre_ALBUM_TITLE}"
    fi
    print_message "\tAlbum Title = ${color_cyan}${tags_ALBUM_TITLE}${color_default}"

    if [ ! -n "${pre_ALBUM_GENRE}" ]
    then
	tags_ALBUM_GENRE=`${tool_CP} -d %G "${cueFile}"`
    else
	tags_ALBUM_GENRE="${pre_ALBUM_GENRE}"
    fi

    [ -n "${tags_ALBUM_GENRE}" ] || tags_ALBUM_GENRE=`grep -m 1 GENRE "${cueFile}" | sed -r -e 's/.?*REM\ GENRE\ (.?*)/\1/g' -e 's:"::g' | tr -d [:cntrl:]`
    [ -n "${tags_ALBUM_GENRE}" ] || tags_ALBUM_GENRE="Other"
    print_message "\tAlbum Genre = ${color_cyan}${tags_ALBUM_GENRE}${color_default}"

    [ -n "${pre_ALBUM_NUMBER}" ] && tags_ALBUM_NUMBER=${pre_ALBUM_NUMBER}
    [ -n "${tags_ALBUM_NUMBER}" ] || tags_ALBUM_NUMBER=`grep -m 1 NUMBER "${cueFile}" | sed -r -e 's/.?*REM\ DISCNUMBER\ (.?*)/\1/g' -e 's:"::g' | tr -d [:cntrl:]`
    [ -n "${tags_ALBUM_NUMBER}" ] && print_message "\tAlbum Disc Number = ${color_cyan}${tags_ALBUM_NUMBER}${color_default}"

    tags_ALBUM_NUMBERS=`grep -m 1 TOTALDISCS "${cueFile}" | sed -r -e 's/.?*REM\ TOTALDISCS\ (.?*)/\1/g' -e 's:"::g' | tr -d [:cntrl:]`
    [ -n "${tags_ALBUM_NUMBERS}" ] && print_message "\tAlbum Number of Discs = ${color_cyan}${tags_ALBUM_NUMBERS}${color_default}"

    [ -n "${pre_ALBUM_DISCID}" ] && tags_ALBUM_DISCID=${pre_ALBUM_DISCID}
    [ -n "${tags_ALBUM_DISCID}" ] || tags_ALBUM_DISCID=`grep -m 1 DISCID "${cueFile}" | sed -r -e 's/.?*REM\ DISCID\ (.?*)/\1/g' -e 's:"::g' | tr -d [:cntrl:]`
    [ -n "${tags_ALBUM_DISCID}" ] && print_message "\tAlbum Disc ID = ${color_cyan}${tags_ALBUM_DISCID}${color_default}"

    if [ ! -n "${pre_ALBUM_DATE}" ]
    then
	tags_ALBUM_DATE=`grep -m 1 DATE "${cueFile}" | sed -r -e 's/.?*REM\ DATE\ (\d)/\1/g' -e 's:"::g' | tr -d [:cntrl:] | tr -d " " | tr -d [:alpha:]`
    else
	tags_ALBUM_DATE=${pre_ALBUM_DATE}
    fi
    [ -n "${tags_ALBUM_DATE}" ] || tags_ALBUM_DATE=0000
    print_message "\tAlbum Date = ${color_cyan}${tags_ALBUM_DATE}${color_default}"

    tags_ALBUM_TRACKS=`${tool_CP} -d %N "${cueFile}"`
    if (( $tags_ALBUM_TRACKS < 10 ))
    then
	tags_ALBUM_ZTRACKS="0$tags_ALBUM_TRACKS"
    else
	tags_ALBUM_ZTRACKS="$tags_ALBUM_TRACKS"
    fi
    print_message "\tNumber of Tracks = ${color_cyan}${tags_ALBUM_ZTRACKS}${color_default}"

    [ -n "${pre_ALBUM_COMMENT}" ] && tags_ALBUM_COMMENT=${pre_ALBUM_COMMENT}
    [ -n "${tags_ALBUM_COMMENT}" ] || tags_ALBUM_COMMENT=`grep -m 1 COMMENT "${cueFile}" | sed -r -e 's/.?*REM\ COMMENT\ (.?*)/\1/g' -e 's:"::g' | tr -d [:cntrl:]`
    [ -n "${tags_ALBUM_COMMENT}" ] || tags_ALBUM_COMMENT="${NAME} v${VER}"
    print_message "\tComment = ${color_cyan}${tags_ALBUM_COMMENT}${color_default}"
}

# function for preparing cover art picture for export
prepare_picture() {

    log_debug "prepare_picture(): tool_IM=${tool_IM}; inPicture=${inPicture}; inPicQuality=${inPicQuality}; inPicSize=${inPicSize}; tempPicture=${tempPicture}"

    ${tool_IM} "${inPicture}" -quality ${inPicQuality} -resize "${inPicSize}>" ${tempPicture}
    if [ $? -ne 0 ]
    then
	print_error "Some error occured while conversion of picture '${color_cyan}${inPicture}${color_default}'!"
	return ${E_CANT_CONVERT_PICTURE}
    else
	print_message "Picture successfully converted."
    fi
}

#function for searching embedded pictures in input file
search_picture() {
    log_debug "search_picture(): inFile=${inFile}; inFileDir=${inFileDir}; inCodec=${inCodec}; tempPicture=${tempPicture}"

    if [ "${inCodec}" = "flac" ]
    then
	${tag_FLAC} --export-picture-to="${tempPicture}" "${inFileDir}/${inFile}" &>/dev/null
	if [ $? -eq 0 ]
	then
	    print_message "Picture successfully exported."
	else
	    tempPicture=""
	    print_message "No picture suitable for export found."
	fi
    else
	tempPicture=""
	print_message "Input format is not supported."
    fi
}


tag_flac_track() {
    tag_Name="$1"
    tag_Value="$2"

    log_debug "tag_flac_track(): tag_Name='$1' tag_Value='$2'"

    log_debug "run ${tag_FLAC}"

    log=`get_tool_log_file`

    ${tag_FLAC} \
    --set-tag="${tag_Name}=${tag_Value}" \
    "${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}" 2>&1 | tee -a "$log"
    if [ $? -ne 0 ]; then
        print_error "Cant tag '${color_cyan}${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}${color_default}'"
        return ${E_CANT_TAG_FLAC}
    fi
}

tag_ogg_track() {
    tag_Name="$1"
    tag_Value="$2"

    ${tag_OGG} -a \
    -t ${tag_Name}="${tag_Value}" \
    "${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}" &>/dev/null
    if [ $? -ne 0 ]; then
        print_error "Cant tag '${color_cyan}${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}${color_default}'"
        return ${E_CANT_TAG_OGG}
    fi
}

tag_ape_track() {
    tag_Name="$1"
    tag_Value="$2"

    ${tag_APE} -i "${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}" -m update \
    -p ${tag_Name}="${tag_Value}" &>/dev/null
    if [ $? -ne 0 ]; then
        print_error "Cant tag '${color_cyan}${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}${color_default}'"
        return ${E_CANT_TAG_APE}
    fi
}

tag_m4a_track() {
    tag_Name="$1"
    tag_Value="$2"

    ${tag_M4A} -${tag_Name} "${tag_Value}" "${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}" &>/dev/null
    if [ $? -ne 0 ]; then
        print_error "Cant tag '${color_cyan}${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}${color_default}'"
        return ${E_CANT_TAG_M4A}
    fi
}

tag_mp3_track() {
    tag_Name="$1"
    tag_Value="$2"

    ${tag_MP3} -2 --set-text-frame="${tag_Name}:${tag_Value}" "${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}" &>/dev/null
    if [ $? -ne 0 ]; then
        print_error "Cant tag '${color_cyan}${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}${color_default}'"
        return ${E_CANT_TAG_MP3}
    fi
}

pic_flac_track() {
    ${tag_FLAC} --import-picture-from="${tempPicture}" "${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}" 2>&1 | tee -a "$log"
    if [ $? -ne 0 ]; then
        print_error "Cant tag '${color_cyan}${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}${color_default}'"
        return ${E_CANT_TAG_FLAC}
    fi
}

pic_mp3_track() {
    ${tag_MP3} --add-image ${tempPicture}:FRONT_COVER "${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}" &>/dev/null
    if [ $? -ne 0 ]; then
        print_error "Cant tag '${color_cyan}${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}${color_default}'"
        return ${E_CANT_TAG_MP3}
    fi
}

# function for track taging
tag_track() {
    case "${outCodec}" in
	"flac" | "flake" )
	    if [ ${onlyTest} -eq 0 ]
	    then
		[ -n "${tags_ALBUM_DISCID}" ] && ( tag_flac_track "DISCID" "${tags_ALBUM_DISCID}" || return ${E_CANT_TAG_FLAC} )
		[ -n "${tags_ALBUM_NUMBER}" ] && ( tag_flac_track "DISCNUMBER" "${tags_ALBUM_NUMBER}" || return ${E_CANT_TAG_FLAC} )
		[ -n "${tags_ALBUM_NUMBERS}" ] && ( tag_flac_track "DISCTOTAL" "${tags_ALBUM_NUMBERS}" || return ${E_CANT_TAG_FLAC} )
		[ -n "${tags_TRACK_COMPOSER}" ] && ( tag_flac_track "COMPOSER" "${tags_TRACK_COMPOSER}" || return ${E_CANT_TAG_FLAC} )
		tag_flac_track "TITLE" "${tags_TRACK_TITLE}" || return ${E_CANT_TAG_FLAC}
		tag_flac_track "ALBUM" "${tags_ALBUM_TITLE}" || return ${E_CANT_TAG_FLAC}
		tag_flac_track "ARTIST" "${tags_TRACK_PERFORMER}" || return ${E_CANT_TAG_FLAC}
		tag_flac_track "DATE" "${tags_ALBUM_DATE}" || return ${E_CANT_TAG_FLAC}
		tag_flac_track "TRACKNUMBER" "${tags_TRACK_ZNUMBER}" || return ${E_CANT_TAG_FLAC}
		tag_flac_track "TRACKTOTAL" "${tags_ALBUM_ZTRACKS}" || return ${E_CANT_TAG_FLAC}
		tag_flac_track "GENRE" "${tags_TRACK_GENRE}" || return ${E_CANT_TAG_FLAC}
		tag_flac_track "COMMENT" "${tags_ALBUM_COMMENT}" || return ${E_CANT_TAG_FLAC}
		[ -n "${tempPicture}" ] && pic_flac_track || return ${E_CANT_TAG_FLAC}
	    fi
	;;
	"ape" | "wv" | "mpc" | "tak" )
	    if [ ${onlyTest} -eq 0 ]
	    then
		[ -n "${tags_ALBUM_DISCID}" ] && ( tag_ape_track "DISCID" "${tags_ALBUM_DISCID}" || return ${E_CANT_TAG_APE} )
		[ -n "${tags_ALBUM_NUMBER}" ] && ( tag_ape_track "MEDIA" "${tags_ALBUM_NUMBER}" || return ${E_CANT_TAG_APE} )
		[ -n "${tags_TRACK_COMPOSER}" ] && ( tag_ape_track "COMPOSER" "${tags_TRACK_COMPOSER}" || return ${E_CANT_TAG_APE} )
		tag_ape_track "TITLE" "${tags_TRACK_TITLE}" || return ${E_CANT_TAG_APE}
		tag_ape_track "ALBUM" "${tags_ALBUM_TITLE}" || return ${E_CANT_TAG_APE}
		tag_ape_track "ARTIST" "${tags_TRACK_PERFORMER}" || return ${E_CANT_TAG_APE}
		tag_ape_track "YEAR" "${tags_ALBUM_DATE}" || return ${E_CANT_TAG_APE}
		tag_ape_track "TRACK" "${tags_TRACK_ZNUMBER}" || return ${E_CANT_TAG_APE}
		tag_ape_track "GENRE" "${tags_TRACK_GENRE}" || return ${E_CANT_TAG_APE}
		tag_ape_track "COMMENT" "${tags_ALBUM_COMMENT}" || return ${E_CANT_TAG_APE}
	    fi
	;;
	"mp3" )
	    if [ ${onlyTest} -eq 0 ]
	    then
		tpos=""
		if [ -n "${tags_ALBUM_NUMBER}" ] 
		then
		    tpos=${tags_ALBUM_NUMBER}
		    [ -n "${tags_ALBUM_NUMBERS}" ] && tpos="${tpos}/${tags_ALBUM_NUMBERS}"
		fi

		[ -n "${tpos}" ] && ( tag_mp3_track "TPOS" "${tpos}" || return ${E_CANT_TAG_MP3} )
		[ -n "${tags_TRACK_COMPOSER}" ] && ( tag_mp3_track "TCOM" "${tags_TRACK_COMPOSER}" || return ${E_CANT_TAG_MP3} )
		tag_mp3_track "TIT2" "${tags_TRACK_TITLE}" || return ${E_CANT_TAG_MP3}
		tag_mp3_track "TALB" "${tags_ALBUM_TITLE}" || return ${E_CANT_TAG_MP3}
		tag_mp3_track "TPE1" "${tags_TRACK_PERFORMER}" || return ${E_CANT_TAG_MP3}
		tag_mp3_track "TYER" "${tags_ALBUM_DATE}" || return ${E_CANT_TAG_MP3}
		tag_mp3_track "TRCK" "${tags_TRACK_ZNUMBER}/${tags_ALBUM_ZTRACKS}" || return ${E_CANT_TAG_MP3}
		tag_mp3_track "TCON" "${tags_TRACK_GENRE}" || return ${E_CANT_TAG_MP3}
		tag_mp3_track "COMM" "${tags_ALBUM_COMMENT}" || return ${E_CANT_TAG_MP3}
		[ -n "${tempPicture}" ] && pic_mp3_track || return ${E_CANT_TAG_MP3}
	    fi
	;;
	"ogg" )
	    if [ ${onlyTest} -eq 0 ]
	    then
		[ -n "${tags_ALBUM_DISCID}" ] && ( tag_ogg_track "DISCID" "${tags_ALBUM_DISCID}" || return ${E_CANT_TAG_OGG} )
		[ -n "${tags_ALBUM_NUMBER}" ] && ( tag_ogg_track "DISCNUMBER" "${tags_ALBUM_NUMBER}" || return ${E_CANT_TAG_OGG} )
		[ -n "${tags_ALBUM_NUMBERS}" ] && ( tag_ogg_track "DISCTOTAL" "${tags_ALBUM_NUMBERS}" || return ${E_CANT_TAG_FLAC} )
		[ -n "${tags_TRACK_COMPOSER}" ] && ( tag_ogg_track "COMPOSER" "${tags_TRACK_COMPOSER}" || return ${E_CANT_TAG_OGG} )
		tag_ogg_track "TITLE" "${tags_TRACK_TITLE}" || return ${E_CANT_TAG_OGG}
		tag_ogg_track "ALBUM" "${tags_ALBUM_TITLE}" || return ${E_CANT_TAG_OGG}
		tag_ogg_track "ARTIST" "${tags_TRACK_PERFORMER}" || return ${E_CANT_TAG_OGG}
		tag_ogg_track "DATE" "${tags_ALBUM_DATE}" || return ${E_CANT_TAG_OGG}
		tag_ogg_track "TRACKNUMBER" "${tags_TRACK_ZNUMBER}" || return ${E_CANT_TAG_OGG}
		tag_ogg_track "TRACKTOTAL" "${tags_ALBUM_ZTRACKS}" || return ${E_CANT_TAG_FLAC}
		tag_ogg_track "GENRE" "${tags_TRACK_GENRE}" || return ${E_CANT_TAG_OGG}
		tag_ogg_track "COMMENT" "${tags_ALBUM_COMMENT}" || return ${E_CANT_TAG_OGG}
	    fi
	;;
	"m4a" )
	    if [ ${onlyTest} -eq 0 ]
	    then
		optionalComment=""
		[ -n "${tags_ALBUM_DISCID}" ] && optionalComment="${optionalComment}, DISCID=${tags_ALBUM_DISCID}"
		[ -n "${tags_ALBUM_NUMBER}" ] && ( tag_m4a_track disk "${tags_ALBUM_NUMBER}" || return ${E_CANT_TAG_M4A} )
		[ -n "${tags_TRACK_COMPOSER}" ] && ( tag_m4a_track writer "${tags_TRACK_COMPOSER}" || return ${E_CANT_TAG_M4A} )
		tag_m4a_track song "${tags_TRACK_TITLE}" || return ${E_CANT_TAG_M4A}
		tag_m4a_track album "${tags_ALBUM_TITLE}" || return ${E_CANT_TAG_M4A}
		tag_m4a_track artist "${tags_TRACK_PERFORMER}" || return ${E_CANT_TAG_M4A}
		tag_m4a_track year "${tags_ALBUM_DATE}" || return ${E_CANT_TAG_M4A}
		tag_m4a_track track "${tags_TRACK_NUMBER}" || return ${E_CANT_TAG_M4A}
		tag_m4a_track tracks "${tags_ALBUM_TRACKS}" || return ${E_CANT_TAG_M4A}
		tag_m4a_track genre "${tags_TRACK_GENRE}" || return ${E_CANT_TAG_M4A}
		tag_m4a_track comment "${tags_ALBUM_COMMENT}${optionalComment}" || return ${E_CANT_TAG_M4A}
	    fi
	;;
    esac
}

# function for decode naming scheme with bash
get_out_file_name() {
    temp_AT=${tags_ALBUM_TITLE//\//\\}
    temp_AP=${tags_ALBUM_PERFORMER//\//\\}
    temp_AG=${tags_ALBUM_GENRE//\//\\}
    temp_AD=${tags_ALBUM_DATE//\//\\}
    temp_TT=${tags_TRACK_TITLE//\//\\}
    temp_TP=${tags_TRACK_PERFORMER//\//\\}
    temp_TG=${tags_TRACK_GENRE//\//\\}

    tstr="${outFormatStr}.${outExt}"
    tstr=${tstr//\%A/${temp_AT}}
    tstr=${tstr//\%G/${temp_AG}}
    tstr=${tstr//\%P/${temp_AP}}
    tstr=${tstr//\%D/${temp_AD}}
    tstr=${tstr//\%t/${temp_TT}}
    tstr=${tstr//\%p/${temp_TP}}
    tstr=${tstr//\%g/${temp_TG}}
    tstr=${tstr//\%n/${tags_TRACK_NUMBER}}
    tstr=${tstr//\%N/${tags_TRACK_ZNUMBER}}
    tstr=${tstr//\%a/${tags_ALBUM_NUMBER}}
    echo ${tstr}
}

# function for track moving
move_track() {
    outFileName=`get_out_file_name`
    outDirName=`dirname "${outFileName}"`
    print_message -n " to '${color_cyan}${outFileName}${color_default}'..."
    if [ ${onlyTest} -eq 0 ]
    then
	if [ ! -d "${outDirName}" ]
	then
	    mkdir -p "${outDirName}"
	    [ $? -eq 0 ] || return ${E_CANT_MKDIR}
	fi
	mv "${tempDirName}/${tags_TRACK_ZNUMBER}.${outExt}" "${outFileName}"
	[ $? -eq 0 ] || return ${E_CANT_MOVE_FILE}
    fi
}

# function for tracks processing
process_tracks() {

    log_debug "process_tracks()"

    [[ "${tags_ALBUM_TRACKS}" == "" || "${tags_ALBUM_TRACKS}" == "0" ]] && return ${E_WRONG_NUM_TRACKS}

    if [ ${tags_ALBUM_TRACKS} != ${totalTracks} ]
    then
	for track in $(ls ${tempDirName}/*.${outExt})
	do
	    newtrack=`printf %0.2d $((10#$(basename ${track} .${outExt})-1))`
	    mv ${track} ${tempDirName}/${newtrack}.${outExt}
	done
	i=0
    else
	i=1
    fi

    while [ ${i} -le ${tags_ALBUM_TRACKS} ]
    do

	if (( $i < 10 ))
	then
	    tags_TRACK_ZNUMBER="0$i"
	else
	    tags_TRACK_ZNUMBER="$i"
	fi
	tags_TRACK_NUMBER="$i"
	set_xterm_title "Processing ${tags_TRACK_NUMBER} of ${tags_ALBUM_TRACKS} [pre]"

	[ $i -eq 0 ] && tags_TRACK_TITLE="Hidden Track" || tags_TRACK_TITLE=`${tool_CP} -n $i -t %t "${cueFile}"`
	tags_TRACK_PERFORMER=`${tool_CP} -n $i -t %p "${cueFile}"`
	tags_TRACK_COMPOSER=`${tool_CP} -n $i -t %c "${cueFile}"`
	tags_TRACK_GENRE=`${tool_CP} -n $i -t %g "${cueFile}"`

	print_message "\tTrack ${color_green}${tags_TRACK_NUMBER}${color_default}: ${color_magenta}${tags_TRACK_TITLE}${color_default}"
	if [[ "${tags_TRACK_PERFORMER}" != "${tags_ALBUM_PERFORMER}" && "${tags_TRACK_PERFORMER}" != "" ]]
	then
	    print_message "\t\tPerformer: ${tags_TRACK_PERFORMER}"
	else
	    tags_TRACK_PERFORMER=${tags_ALBUM_PERFORMER}
	fi
	if [[ "${tags_TRACK_COMPOSER}" != "${tags_ALBUM_COMPOSER}" && "${tags_TRACK_COMPOSER}" != "" ]]
	then
	    print_message "\t\tComposer: ${tags_TRACK_COMPOSER}"
	else
	    tags_TRACK_COMPOSER=${tags_ALBUM_COMPOSER}
	fi
	if [[ "${tags_TRACK_GENRE}" != "${tags_ALBUM_GENRE}" && "${tags_TRACK_GENRE}" != "" ]]
	then
	    print_message "\t\tGenre: ${tags_TRACK_GENRE}"
	else
	    tags_TRACK_GENRE=${tags_ALBUM_GENRE}
	fi

	if [ ${putTags} -eq 1 ]
	then
	    set_xterm_title "Processing ${tags_TRACK_NUMBER} of ${tags_ALBUM_TRACKS} [tag]"
	    print_message -n "\t${color_green}*${color_default} Taging..."
	    chk_error=0
	    tag_track
	    chk_error=$?
	    if [ ${chk_error} -eq 0 ]
	    then
		print_message "\t[${color_green}ok${color_default}]."
	    else
		print_message "\t[${color_red}failed${color_default}]"
		[ ${onlyTest} -eq 0 ] && return ${chk_error}
	    fi
	fi

	print_message -n "\t${color_green}*${color_default} Moving..."
	set_xterm_title "Processing ${tags_TRACK_NUMBER} of ${tags_ALBUM_TRACKS} [move]"
	chk_error=0
	move_track
	chk_error=$?
	if [ ${chk_error} -eq 0 ]
	then
	    print_message "\t[${color_green}ok${color_default}]."
	else
	    print_message "\t[${color_red}failed${color_default}]"
	    [ ${onlyTest} -eq 0 ] && return ${chk_error}
	fi
	i=$(($i + 1))
    done
}

# function called on exit
onexit() {
    echo ""
    str=`ps ax | grep shntool | grep -v grep`
    if [ -n "${str}" ]
    then
	killall -q -I -- ${codec_OUT}
	killall -q -I -- ${codec_IN}
	killall -q -I -- shntool
	killall -q -I -- cuebreackpoints
    fi
    if [[ "${tempDirName}" != "." ]]
    then
	[ -d "${tempDirName}" ] && rm -rf "${tempDirName}"
    else
	rm -f "${file_splitlog}" "${file_splitlogwork}"
    fi
    ${PROMPT_COMMAND}
    [[ "$1" == "halt" ]] && exit ${E_UNK}
    ecode=$1
    [ ! -n "${ecode}" ] && ecode=0
    exit ${ecode}
}

onhalt() {
    print_message "\n${color_red}Halted!${color_default}"
    onexit halt
}

run_section() {
    title=$1
    func=$2
    msg=$3

    set_xterm_title "${title}"
    print_message "${color_yellow}${title}${color_default}"
    chk_error=0
    ${func}
    chk_error=$?
    if [ ${chk_error} -ne 0 ]
    then
	[ ${onlyTest} -eq 0 ] && onexit ${chk_error}
    fi
    print_message "${msg}"
}

# --== MAIN PROGRAM ==--

while getopts ":CXRVc:f:o:dD:G:l:qsn:Q:M:B:I:O:i:p:j:r:hA:P:K:N:WL:e" Option
do
    case ${Option} in
	e )
	    logDebug=1
            export logDebug
	;;
	W )
	    inFile2WAV=1
	;;
	C )
	    useColors=1
	;;
	X )
	    useXTitle=1
	;;
	c )
	    outCodec=`echo ${OPTARG} | tr [:upper:] [:lower:]`
	;;
	f )
	    fromCP=${OPTARG}
	    tool_F_needed=1
	    tool_IC_needed=1
	;;
	o )
	    outFormatStr="${OPTARG}"
	;;
	L )
	    logFile=`readlink -m "${OPTARG}"`
            log_debug "Log file = $logFile"
            export logFile
	;;
	d )
	    putTags=0
	;;
	R )
	    onlyTest=0
	;;
	V )
	    print_version
	    onexit
	;;
	A )
	    pre_ALBUM_TITLE="${OPTARG}"
	;;
	P )
	    pre_ALBUM_PERFORMER="${OPTARG}"
	;;
	K )
	    pre_ALBUM_COMPOSER="${OPTARG}"
	;;
	D )
	    pre_ALBUM_DATE="${OPTARG}"
	;;
	G )
	    pre_ALBUM_GENRE="${OPTARG}"
	;;
	N )
	    pre_ALBUM_NUMBER=${OPTARG}
	;;
	I )
	    pre_ALBUM_DISCID="${OPTARG}"
	;;
	O )
	    pre_ALBUM_COMMENT="${OPTARG}"
	;;
	l )
	    outCodecLevel=`echo ${OPTARG} | tr [:upper:] [:lower:]`
	;;
	q )
	    quiteMode=1
	;;
	s )
	    splitInTest=1
	;;
	n )
	    niceness=`echo ${OPTARG} | sed -r 's/[^-0-9]//g'`
	    [ `echo "${niceness} < -19" | bc` -eq 1 ] && niceness=-19
	    [ `echo "${niceness} > 19" | bc` -eq 1 ] && niceness=19
	;;
	Q )
	    outCodecQuality=`echo ${OPTARG} | sed -r 's/[^-0-9\.]//g'`
	    [ `echo "${outCodecQuality} < -1" | bc` -eq 1 ] && outCodecQuality=-1
	    [ `echo "${outCodecQuality} > 10" | bc` -eq 1 ] && outCodecQuality=10
	    outCodecLevel=3
	;;
	M )
	    outCodecMode=`echo ${OPTARG} | tr [:lower:] [:upper:]`
	    if [[ "${outCodecMode}" != "C" && "${outCodecMode}" != "V" ]]
	    then
		outCodecMode="V"
	    fi
	;;
	B )
	    outCodecBitRate=`echo ${OPTARG} | sed -r 's/[^0-9\.]//g'`
	    [ `echo "${outCodecBitRate} < 32" | bc` -eq 1 ] && outCodecBitRate=32
	    [ `echo "${outCodecBitRate} > 500" | bc` -eq 1 ] && outCodecBitRate=500
	    outCodecLevel=3
	;;
	i )
	    inFile=${OPTARG}
	;;
	p )
	    inPicture=${OPTARG}
	    tool_IM_needed=1
	;;
	j )
	    inPicQuality=`echo ${OPTARG} | sed -r 's/[^0-9\.]//g'`
	    [ `echo "${inPicQuality} < 1" | bc` -eq 1 ] && inPicQuality=1
	    [ `echo "${inPicQuality} > 100" | bc` -eq 1 ] && inPicQuality=100
	;;
	r )
	    inPicSize=${OPTARG}
	;;
	h )
	    print_help
	    onexit
	;;
	* ) print_error "Unimplemented option chosen." ;;   # DEFAULT
    esac
done

# Reset all colors to None
if [ ${useColors} -eq 0 ]
then
    color_default=""
    color_red=""
    color_green=""
    color_yellow=""
    color_cyan=""
    color_magenta=""
fi

# --== Check options ==--
if [ $# -eq "$NO_ARGS" ]  # Script invoked with no command-line args?
then
    print_help
    onexit $E_OPTERROR    # Exit and explain usage, if no argument(s) given.
fi

shift $(($OPTIND - 1))

set_xterm_title "Starting..."

cueFile="$1"

if [ ! -n "${cueFile}" ]
then
    print_help
    exit $E_OPTERROR
fi

print_info

trap onhalt SIGTERM
trap onhalt SIGKILL
trap onhalt SIGINT

[ ! ${niceness} -eq 0 ] && print_message "\tSetting niceness level to '${color_yellow}${niceness}${color_default}'\n"
renice ${niceness} $$ &>/dev/null

if [ ! -e "${cueFile}" -o ! -f "${cueFile}" ]
then
    print_error "File '${color_cyan}${cueFile}${color_default}' dont exists or not a regular file!"
    onexit ${E_NOT_CUE_FILE}
fi

if [ -n "${inFile}" ]
then
    if [ -e "${inFile}" ]
    then
	inFileDir=`dirname "${inFile}"`
	inFile=`basename "${inFile}"`
    else
	print_error "File '${inFile}' not found! Setting to default path..."
	inFile=""
    fi
else
    inFileDir=`dirname "${cueFile}"`
fi

[ "${inFileDir}" = "." ] && inFileDir=`pwd`

tempDirName=`mktemp -q -d --tmpdir ${scriptName}-XXXXXX`
[ -n "${tempDirName}" ] || tempDirName="."

testformat=`echo ${outFormatStr} | sed -e 's:%n::' -e 's:%N::' -e 's:%t::'`
if [ "${outFormatStr}" = "${testformat}" ]
then
    print_error "Put any of '%n, %N, %t' changable tag descriptors or file writing errors may be occured! Setting to default '%N'..."
    outFormatStr="%N"
fi

run_section "Searching for tools..." search_tools
run_section "Fixing CUE if needed..." prepare_and_fix_cue
run_section "Recode CUE if needed..." recode_cue

# setup quality
_echoCodecLevel=""
case ${outCodecLevel} in
    "best" | 0 )
	outCodecLevel=0
	_echoCodecLevel="best"
	case ${outCodec} in
	    "mp3" )
		outCodecMode="V"
		outCodecQuality=0
	    ;;
	    "ogg" )
		outCodecMode="V"
		outCodecQuality=10
	    ;;
	    "m4a" )
		outCodecMode="V"
		outCodecQuality=500
	    ;;
	esac
    ;;
    "fast" | 1 )
	outCodecLevel=1
	_echoCodecLevel="fast"
	case ${outCodec} in
	    "mp3" )
		outCodecMode="V"
		outCodecQuality=7
	    ;;
	    "ogg" )
		outCodecMode="V"
		outCodecQuality=1
	    ;;
	    "m4a" )
		outCodecMode="V"
		outCodecQuality=20
	    ;;
	esac
    ;;
    "mid" | 2 )
	outCodecLevel=2
	_echoCodecLevel="mid"
	case ${outCodec} in
	    "mp3" )
		outCodecMode="V"
		outCodecQuality=2
	    ;;
	    "ogg" )
		outCodecMode="V"
		outCodecQuality=6
	    ;;
	    "m4a" )
		outCodecMode="V"
		outCodecQuality=192
	    ;;
	esac
    ;;
    "custom" | 3 )
	outCodecLevel=3
	_echoCodecLevel="custom"
    ;;
    * )
	print_error "Unknown compression level '${outCodecLevel}'..."
	print_levels
	outCodecLevel=0
	_echoCodecLevel="best"
    ;;
esac


# setup codecs quality limits
case "${outCodec}" in
    "mp3")
	[ `echo "${outCodecQuality} < 0" | bc` -eq 1 ] && outCodecQuality=0
	[ `echo "${outCodecQuality} > 9" | bc` -eq 1 ] && outCodecQuality=9
	if [ `echo "${outCodecBitRate} > 256" | bc` -eq 1 ]
	then
	    outCodecBitRate=320
	elif [ `echo "${outCodecBitRate} > 192" | bc` -eq 1 ]
	then
	    outCodecBitRate=256
	elif [ `echo "${outCodecBitRate} > 128" | bc` -eq 1 ]
	then
	    outCodecBitRate=192
	elif [ `echo "${outCodecBitRate} > 96" | bc` -eq 1 ]
	then
	    outCodecBitRate=128
	elif [ `echo "${outCodecBitRate} > 64" | bc` -eq 1 ]
	then
	    outCodecBitRate=96
	elif [ `echo "${outCodecBitRate} > 32" | bc` -eq 1 ]
	then
	    outCodecBitRate=64
	else
	    outCodecBitRate=32
	fi
    ;;
    "m4a")
	[ `echo "${outCodecQuality} < 10" | bc` -eq 1 ] && outCodecQuality=10
	[ `echo "${outCodecQuality} > 500" | bc` -eq 1 ] && outCodecQuality=500
	[ `echo "${outCodecBitRate} < 10" | bc` -eq 1 ] && outCodecBitRate=10
	[ `echo "${outCodecBitRate} > 500" | bc` -eq 1 ] && outCodecBitRate=500
    ;;
    "ogg")
	[ `echo "${outCodecQuality} < -1" | bc` -eq 1 ] && outCodecQuality=-1
	[ `echo "${outCodecQuality} > 10" | bc` -eq 1 ] && outCodecQuality=10
	[ `echo "${outCodecBitRate} < 32" | bc` -eq 1 ] && outCodecBitRate=32
	[ `echo "${outCodecBitRate} > 500" | bc` -eq 1 ] && outCodecBitRate=500
    ;;
esac

run_section "Check output codec..." check_outCodec "\tSetting output codec compression level to '${color_yellow}${_echoCodecLevel}${color_default}'\n"
run_section "Check input codec..." check_inCodec
run_section "Searching for encoder/decoder tools..." search_dencoders

if [ ${putTags} -eq 1 ]
then
    run_section "Searching for taging tools..." search_tagers
fi

run_section "Reading album info..." read_album_info
[ ${inFile2WAV} -ne 0 ] && run_section "Recode to WAV..." recode_to_wav

tempPicture="${tempDirName}/picture.jpg"
if [ -n "${inPicture}" ]
then
    run_section "Preparing cover art picture..." prepare_picture
else
    run_section "Searching for cover art picture in input file..." search_picture
fi

if [ $logDebug -eq 0 ]; then
    run_section "Start splitting..." split_image
else
    run_section "Start splitting..." split_image_debug
fi

run_section "Processing tracks..." process_tracks

if [ ${onlyTest} -eq 1 ]
then
    print_message "\n${color_magenta}${NAME} executed in testing mode! To get real work rerun it with -R option or${color_default}"

    answ="N"
    print_message -n "\n${color_magenta}Apply selected options?${color_default}[y/${answ}]: "
    read answ
    answ=`echo ${answ} | tr [:upper:] [:lower:]`

    if [ "${answ}" = "y" ]; then

        onlyTest=0

        run_section "Reading album info..." read_album_info
        [ ${inFile2WAV} -ne 0 ] && run_section "Recode to WAV..." recode_to_wav

        if [ $logDebug -eq 0 ]; then
            run_section "Start splitting..." split_image
        else
            run_section "Start splitting..." split_image_debug
        fi

        run_section "Processing tracks..." process_tracks

    fi

fi

onexit

}
