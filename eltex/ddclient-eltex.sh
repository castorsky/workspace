#!/bin/sh
USER=user
PWD=user
IP=192.168.33.1

LOGINURL="http://${IP}/login"
INFOURL="http://${IP}/wancfg.cmd?action=view&type=detail"
POSTDATA="username=${USER}&password=${PWD}"

if [ ! -e /usr/bin/wget ]; then
    echo "wget executable not found, trying cUrl instead."
    if [ ! -e /usr/bin/curl ]; then
        echo "cUrl executable not found either, exiting now."
        exit 1
    else
        echo "wget not found. Using cUrl."
        EXEC="/usr/bin/curl"
        PARAMLOGIN="-c cookies.txt -o log.txt --data ${POSTDATA}"
        PARAMGET="-b cookies.txt -o result.html"
    fi
else
    echo "wget found. Using wget."
    EXEC="/usr/bin/wget"
    PARAMLOGIN="--save-cookies cookies.txt --keep-session-cookies --delete-after --post-data ${POSTDATA}"
    PARAMGET="--load-cookies cookies.txt -O result.html"
fi

mkdir /tmp/ddclient-eltex
cd /tmp/ddclient-eltex

echo "Logging into Eltex router at ${IP}."
$EXEC $PARAMLOGIN $LOGINURL # 2>/dev/null
echo "Getting WAN connection details."
$EXEC $PARAMGET $INFOURL # 2>/dev/null
echo "Parsing output."
cat result.html | grep "IPv4 Address" | grep -Po "((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"

cd /
rm -rf /tmp/ddclient-eltex
