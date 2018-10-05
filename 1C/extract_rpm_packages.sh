#!/bin/bash

if [[ $# -eq 0 ]]
then
	echo "Usage: scrpit.sh [directory_with_packages]"
	echo -e "Script will scan directory for RPM packages of 1C: Enterprise 8.3 and extract them for multi-platform usage.\nAfter install that packages will be placed at /opt/1C/v8.3.x-xxxx\n1C: Server is not usable, it is being installed as dependency for client."
	exit 1
fi

TARGETPATH=$1
ENTERPRISE="1C_Enterprise83"
CURL="/usr/bin/curl"
VERS1C="1"

if [[ ! -d $TARGETPATH ]]; then
	echo "Directory does not exist."
	exit 1
fi

for FILENAME in $(find ${TARGETPATH} -iname "${ENTERPRISE}*.rpm")
do
	cd ${TARGETPATH}
	FILE=`basename "$FILENAME"`
	DIR=`dirname "$FILENAME"`
	VERS1C=`echo $FILE | sed -E 's/.*(8\.3\.[0-9]+-[0-9]{4}).*rpm/\1/'` # 8.3.10-2369
	SHORTVER=`echo ${VERS1C} | sed -E "s/[^0-9]//g" | sed -E 's/[0-9]{2}(.*)/\1/'` # 102369
	PACKAGE=`echo $FILE | sed -E "s/^(${ENTERPRISE}.*)-8\.3\.[0-9]+-.*/\1/"` # 1c-enterprise83-server-nls
	NEWPACKAGE=`echo $FILE | sed -E "s/${VERS1C}/${VERS1C}_repack/" | sed -E "s/rpm$/tar.gz/"`
	echo -n "Processing $FILENAME..."
#	echo -e "TARGETPATH=$TARGETPATH\nFILENAME=$FILENAME\nFILE=$FILE\nDIR=$DIR\nVERS1C=$VERS1C\nSHORTVER=$SHORTVER\nPACKAGE=$PACKAGE\nNEWPACKAGE=$NEWPACKAGE\n"
	mkdir -p "$PACKAGE"
	rpm2cpio ${FILE} | cpio -idm -D "$PACKAGE" &>/dev/null
	if [[ -d "${PACKAGE}/opt/1C/v8.3" ]]; then
		mv "${PACKAGE}/opt/1C/v8.3" "${PACKAGE}/opt/1C/v${VERS1C}" 
	fi
	# Delete /etc folder
	if [[ -d "${PACKAGE}/etc" ]]; then
		rm -rf "${PACKAGE}/etc"
	fi
	# Rename and edit *.desktop files
	if [[ -d "${PACKAGE}"/usr/share/applications ]]; then
		for FNAME in "${PACKAGE}"/usr/share/applications/*.desktop; do
			NEWNAME=`echo $FNAME | sed -E "s/(.*)(\.desktop)/\1_${VERS1C}\2/"`
			mv "$FNAME" "$NEWNAME"
			sed -i -E "s/(v8.3|Enterprise|Предприятие)/v${VERS1C}/g" $NEWNAME
		done
	fi
	# Pack every package to tar.gz archive
	tar -czpf ${NEWPACKAGE} -C "$PACKAGE/" .
	rm -rf "${PACKAGE}/"
	echo " done. Repacked into $NEWPACKAGE."
	rm -rf "$FILE"
	cd -
done

echo "Processing additional packages..."
AUXPKGS="libpng12-1.2.57-1.fc26.x86_64.rpm cairo-1.14.10-1.fc26.x86_64.rpm \
    libicu-57.1-6.fc26.x86_64.rpm webkitgtk3-2.4.11-5.fc26.x86_64.rpm"
ARCHIVEURL="https://archives.fedoraproject.org/pub/archive/fedora/linux/releases/26/Everything/x86_64/os/Packages/"
TEMPDIR="/tmp/1crepack"
if [[ ! -d $TEMPDIR ]]; then
	echo "Seems that packages was not downloaded. Trying to download them."
	mkdir -p $TEMPDIR
fi

cd "$TARGETPATH"
AUXDIR="auxpkgs/opt/1C/v${VERS1C}/x86_64"
test -d $AUXDIR || mkdir -p $AUXDIR
for PKGNAME in $AUXPKGS; do
	if [[ ! -f "$TEMPDIR/$PKGNAME" ]]; then
		echo -n "Downloading $PKGNAME..."
		LITER="$(echo $PKGNAME | head -c 1)"
		$CURL -s "$ARCHIVEURL/$LITER/$PKGNAME" -o "$TEMPDIR/$PKGNAME"
		echo " Success."
	else
		echo "Package $PKGNAME already downloaded."
	fi
	rpm2cpio "$TEMPDIR/$PKGNAME" | cpio -idm -D "auxpkgs/temp" &>/dev/null
done
for LIBFILE in $(ls "auxpkgs/temp/usr/lib64/"); do
	cp -P --preserve=links "auxpkgs/temp/usr/lib64/$LIBFILE" "$AUXDIR" &>/dev/null
done
rm -rf "auxpkgs/temp"
tar -czpf "1C-auxlibs-$VERS1C.tar.gz" -C "auxpkgs/" .
rm -rf "auxpkgs"
cd -
