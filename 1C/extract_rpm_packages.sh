#!/bin/bash

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

find ${TARGETPATH} -iname "${ENTERPRISE}*.rpm" | while read FILENAME
do
	cd ${TARGETPATH}
	FILE=`basename "$FILENAME"`
	DIR=`dirname "$FILENAME"`
	VERSION=`echo $FILE | sed -E 's/.*(8\.3\.[0-9]+-[0-9]{4}).*rpm/\1/'` # 8.3.10-2369
	SHORTVER=`echo ${VERSION} | sed -E "s/[^0-9]//g" | sed -E 's/[0-9]{2}(.*)/\1/'` # 102369
	PACKAGE=`echo $FILE | sed -E "s/^(${ENTERPRISE}.*)-8\.3\.[0-9]+-.*/\1/"` # 1c-enterprise83-server-nls
	NEWPACKAGE=`echo $FILE | sed -E "s/${VERSION}/${VERSION}_repack/" | sed -E "s/rpm$/tar.gz/"`
	echo "Processing $FILENAME..."
#	echo -e "TARGETPATH=$TARGETPATH\nFILENAME=$FILENAME\nFILE=$FILE\nDIR=$DIR\nVERSION=$VERSION\nSHORTVER=$SHORTVER\nPACKAGE=$PACKAGE\nNEWPACKAGE=$NEWPACKAGE\n"
	mkdir "$DIR/$PACKAGE"
	rpm2cpio ${FILENAME} | cpio -idm -D "$DIR/$PACKAGE" &>/dev/null
	if [[ -d "${DIR}/${PACKAGE}/opt/1C/v8.3" ]]; then
		mv "${DIR}/${PACKAGE}/opt/1C/v8.3" "${DIR}/${PACKAGE}/opt/1C/v${VERSION}" 
	fi
#	# Delete /etc folder
	if [[ -d "${DIR}/${PACKAGE}/etc" ]]; then
		rm -rf "${DIR}/${PACKAGE}/etc"
	fi
	# Rename and edit *.desktop files
	if [[ -d "${DIR}/${PACKAGE}"/usr/share/applications ]]; then
		for FNAME in "${DIR}/${PACKAGE}"/usr/share/applications/*.desktop; do
			NEWNAME=`echo $FNAME | sed -E "s/(.*)(\.desktop)/\1_${VERSION}\2/"`
			mv "$FNAME" "$NEWNAME"
			sed -i -E "s/(v8.3|Enterprise|Предприятие)/v${VERSION}/g" $NEWNAME
		done
	fi
	# Pack every package to tar.gz archive
##	tar -cpf - -C "${DIR}/${PACKAGE}/" . | 7z a -si $NEWPACKAGE &>/dev/null
	tar -czpf ${NEWPACKAGE} -C "$DIR/$PACKAGE/" .
	rm 	-rf "${DIR}/${PACKAGE}/"
	echo "$NEWPACKAGE packed!"
	cd -
done
