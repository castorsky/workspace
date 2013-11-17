#!/bin/bash
PATH1="/home/castor/temp/error/etc"
PATH2="/home/castor/temp/correct/etc"
cd ${PATH1}
find . -iname "*" -type f | while read FILE; do
    HASH1=""
    HASH2=""
    if [ -e "${PATH2}/${FILE}" ]; then
        HASH1=`sha1sum "${FILE}" | awk -e '{ print $1 }'`
        HASH2=`sha1sum "$PATH2/${FILE}" | awk -e '{ print $1 }'`
        echo -e "Examining file ${FILE}\nHashes are: ${HASH1}, ${HASH2}"
        if [ ${HASH1} == ${HASH2} ]; then
            echo "Files are identical. We can remove them. Processing..."
            rm -f "${FILE}"
            rm -f "${PATH2}/${FILE}"
        fi
    fi
done