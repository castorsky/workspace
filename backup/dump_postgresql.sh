#!/bin/bash
# This script intended to be used on CentOS/RHEL 7

# Check if 'bc' is installed. It's not critical but I prefer not to
# make calculations of seconds by hand.
if [ ! -f "/usr/bin/bc" ]; then
     echo -e "Calculator not installed.\nRun 'yum install bc'"
fi

# List non-template bases on this server
QUERY="SELECT datname FROM pg_database WHERE datistemplate = false;"
BASES=`echo ${QUERY} | psql -t`

# Default directory for backups
BACKDIR="/var/lib/pgsql/9.6/backups"

# Number of days we will store backups
DAYS=60
MAXAGE=`echo "${DAYS}*24*60^2" | bc`

# Current date in UNIX epoch format
EPOCH=`date +%s`

for BASE in $BASES
do
    for FILE in `find ${BACKDIR} -iname "${BASE}*"`
    do
        FILEEPOCH=`echo $FILE | sed -E 's/.*_ep([0-9]+).*/\1/'`
        DIFF=$(expr ${EPOCH} - ${FILEEPOCH})
        if [[ "$DIFF" -gt "$MAXAGE" ]]
        then
            rm -f $FILE
        fi
    done
    /usr/bin/pg_dump ${BASE} -Fc > ${BACKDIR}/${BASE}_`date +%Y-%m-%d_%H\:%M`_ep${EPOCH}.dump
done
