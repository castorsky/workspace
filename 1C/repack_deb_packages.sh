#!/bin/bash
if [[ ! -f /usr/bin/rename ]]; then
	echo -e "RENAME utility not found. Install it with\n$ sudo apt install rename\nand try again."
	exit
fi

if [[ $# -eq 0 ]]
then
	echo "Usage: scrpit.sh [directory_with_packages]"
	echo -e "Script will scan directory for DEB packages of 1C: Enterprise 8.3 and repack them for multi-platform usage.\nAfter install that packages will be placed at /opt/1C/v8.3.x-xxxx\n1C: Server is not usable, it is being installed as dependency for client."
	exit 1
fi

TARGETPATH=$1
ENTERPRISE="1c-enterprise83"

if [[ ! -d $TARGETPATH ]]; then
	echo "Directory does not exist."
	exit 1
fi

find $TARGETPATH -iname "${ENTERPRISE}*.deb" | while read FILENAME
do
	FILE=`basename "$FILENAME"`
	DIR=`dirname "$FILENAME"`
	VERSION=`echo $FILE | sed -E 's/.*(8\.3\.[0-9]+-[0-9]{4}).*deb/\1/'` # 8.3.10-2369
	SHORTVER=`echo ${VERSION} | sed -E "s/[^0-9]//g" | sed -E 's/[0-9]{2}(.*)/\1/'` # 102369
	PACKAGE=`echo $FILE | sed -E "s/^(${ENTERPRISE}.*)_8\.3\.[0-9]+-.*/\1/"` # 1c-enterprise83-server-nls
	NEWPACKAGE=`echo $FILE | sed -E "s/${ENTERPRISE}/${ENTERPRISE}${SHORTVER}/"`
	dpkg-deb -x $FILENAME ${DIR}/${PACKAGE}
	dpkg-deb -e $FILENAME ${DIR}/${PACKAGE}/DEBIAN
	sed -i -E ""s/${ENTERPRISE}/${ENTERPRISE}${SHORTVER}/g"" ${DIR}/${PACKAGE}/DEBIAN/control
	if [[ -d "${DIR}/${PACKAGE}/opt/1C/v8.3" ]]; then
		mv "${DIR}/${PACKAGE}/opt/1C/v8.3" "${DIR}/${PACKAGE}/opt/1C/v${VERSION}" 
	fi
	# Delete all icons
        if [[ -d "${DIR}/${PACKAGE}/usr/share/icons" ]]; then
            rm -rf "${DIR}/${PACKAGE}/usr/share/icons"
    	fi
    	# Delete /etc folder
        if [[ -d "${DIR}/${PACKAGE}/etc" ]]; then
            rm -rf "${DIR}/${PACKAGE}/etc"
        fi
        # Delete all non-control files in DEBIAN folder
	find ${DIR}/${PACKAGE}/DEBIAN/ ! -iname "control" -iname "*" -type f -delete
	# Rename and edit *.desktop links
	if [[ -d ${DIR}/${PACKAGE}/usr/share/applications ]]; then
		for FNAME in "${DIR}/${PACKAGE}"/usr/share/applications/*.desktop; do
			NEWNAME=`echo $FNAME | sed -E "s/(.*)(\.desktop)/\1_${VERSION}\2/"`
			mv "$FNAME" "$NEWNAME"
			sed -i -E "s/(v8.3|Enterprise|Предприятие)/v${VERSION}/g" $NEWNAME
		done
#		rename "s/(.*)(\.desktop)/\1_${VERSION}\2/" ${DIR}/${PACKAGE}/usr/share/applications/*.desktop &>/dev/null
#		sed -i -E "s/(v8.3|Enterprise|Предприятие)/v${VERSION}/g" ${DIR}/${PACKAGE}/usr/share/applications/*.desktop
	fi
	dpkg-deb -b ${DIR}/${PACKAGE} ${DIR}/${NEWPACKAGE}
done
