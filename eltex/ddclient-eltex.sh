#!/bin/bash
USER=user
PWD=user
IP=192.168.73.1

LOGINURL="http://${IP}/login?username=${USER}&password=${PWD}"
INFOURL="http://${IP}/wancfg.cmd?action=view&type=detail"

if [ ! -e /usr/bin/wget ]; then
#    echo "wget executable not found, trying cUrl instead."
    if [ ! -e /usr/bin/curl ]; then
#        echo "cUrl executable not found either, exiting now."
        exit 1
    else
        EXEC="/usr/bin/curl"
        PARAMLOGIN="-c cookies.txt -o log.txt"
        PARAMGET="-b cookies.txt -o result.html"
    fi
else
    EXEC="/usr/bin/wget"
    PARAMLOGIN="--save-cookies cookies.txt --keep-session-cookies --delete-after"
    PARAMGET="--load-cookies cookies.txt -O result.html"
fi

mkdir /tmp/ddclient-eltex
cd /tmp/ddclient-eltex

$EXEC $PARAMLOGIN $LOGINURL 2>/dev/null
$EXEC $PARAMGET $INFOURL 2>/dev/null
cat result.html | grep "IPv4 Address" | grep -Po "((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"

cd /
rm -rf /tmp/ddclient-eltex
