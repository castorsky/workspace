#!/bin/bash

if [[ ! -f /usr/bin/rename ]]; then
    echo -e "RENAME utility not found. Install it with\n$ sudo apt install rename\nand try again."
    exit
fi

if [[ $# -eq 0 ]]
then
	echo "Usage: scrpit.sh [directory_with_packages]"
	echo -e "Script will scan directory for RPM packages of 1C: Enterprise 8.3 and extract them for multi-platform usage.\nAfter install that packages will be placed at /opt/1C/v8.3.x-xxxx\n1C: Server is not usable, it is being installed as dependency for client."
	exit 1
fi

TARGETPATH=$1
ENTERPRISE="1C_Enterprise83"

if [[ ! -d $TARGETPATH ]]; then
	echo "Directory does not exist."
	exit 1
fi

find $TARGERPATH -iname "${ENTERPRISE}*.rpm" | while read FILENAME
do
    FILE=`basename "$FILENAME"`
    DIR=`dirname "$FILENAME"`
    VERSION=`echo $FILE | sed -E 's/.*(8\.3\.[0-9]+-[0-9]{4}).*deb/\1/'` # 8.3.10-2369
    SHORTVER=`echo ${VERSION} | sed -E "s/[^0-9]//g" | sed -E 's/[0-9]{2}(.*)/\1/'` # 102369
    PACKAGE=`echo $FILE | sed -E "s/^(${ENTERPRISE}.*)_8\.3\.[0-9]+-.*/\1/"` # 1c-enterprise83-server-nls
    NEWPACKAGE=`echo $FILE | sed -E "s/${ENTERPRISE}/${ENTERPRISE}${SHORTVER}/"`
    echo -e "TARGETPATH=$TARGETPATH\nFILENAME=$FILENAME\nFILE=$FILE\nDIR=$DIR\nVERSION=$VERSION\nSHORTVER=$SHORTVER\nPACKAGE=$PACKAGE\nNEWPACKAGE=$NEWPACKAGE\n"
done