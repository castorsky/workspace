#!/bin/bash

# List of infobases for dumping DTs
BASES="base1 base2"

SRV1S="server_fqdn_or_ip"
NAS="server_fqdn_or_ip"
LOGIN_1S="root"
LOGIN_NAS="backup"
IBUSER="backup_user"
IBPWD="pleasechangeme"
CLSTR_USER="cluster_admin"
CLSTR_PWD="pleasechangeme"
BLKSTART=`date +%FT%T`
BLKEND=`date -d '+3 hours' +%FT%T`
DATE=`date +%F_%H%M`
STAMP=`date +%s`
BLKCODE="pleasechangeme"
BLKMSG="Подождите, идет выгрузка. Блокировка будет снята не позднее $BLKEND"
SSH_1S="$(type -p ssh) -l $LOGIN_1S $SRV1S"
SSH_NAS="$(type -p ssh) -l $LOGIN_NAS $NAS"
RAS="/opt/1C/v8.3/x86_64/ras"
RAC="/opt/1C/v8.3/x86_64/rac"
CLIENT="/opt/1C/v8.3/x86_64/1cv8"
BACKDIR="/backup/tmp"
LOGDIR="/backup/log"
NASDIR="/mnt/vpool/backup/1S"
MAXAGE=`echo "14*24*60^2" | bc` # 14 days
XVFB="$(type -p xvfb-run)"
if [ -z $XVFB ]; then
    echo "xfvb package not found. Exiting!"
    exit 1
fi

# Remove old DTs
rm -rf $BACKDIR/*

# Kill remain RAS processes before starting new one
$SSH_1S "ps -C ras -o pid --no-headers | xargs kill > foo.out 2> foo.err < /dev/null"
$SSH_1S "nohup $RAS cluster > foo.out 2> foo.err < /dev/null &"
# Get cluster UUID
CLUSTER=`$SSH_1S "$RAC cluster list" | grep cluster | awk -F ' : ' '{ print $2 }'`

for BASE in $BASES; do
    # Get infobase UUID in cluster
    BASEID=`$SSH_1S "$RAC infobase --cluster=$CLUSTER summary list \
        --cluster-user=$CLSTR_USER --cluster-pwd='$CLSTR_PWD'" | grep -B 1 -i $BASE | \
        grep infobase | awk -F ' : ' '{ print $2 }'`
    # Block infobase to gain monopoly access and wait 2 minutes
    $SSH_1S "$RAC infobase --cluster=$CLUSTER update --infobase=$BASEID --infobase-user=\"$IBUSER\" \
        --infobase-pwd=\"$IBPWD\" --denied-from=$BLKSTART --denied-to=$BLKEND --sessions-deny=on \
        --scheduled-jobs-deny=on --permission-code=\"$BLKCODE\" --denied-message=\"$BLKMSG\" \
        --cluster-user=$CLSTR_USER --cluster-pwd='$CLSTR_PWD'"
    sleep 2m
    # Dump DT file from infobase
    DTFILE=${BACKDIR}/${BASE}_${DATE}_stamp${STAMP}.dt
    $XVFB $CLIENT DESIGNER /S "${SRV1S}/${BASE}" /N "$IBUSER" /P "$IBPWD" /UC "$BLKCODE" \
        /Out "${LOGDIR}/${BASE}.1s.log" /DumpIB "$DTFILE" > /dev/null 2>&1
    # Start copying DT to NAS in background
    nohup scp "$DTFILE" ${LOGIN_NAS}@${NAS}:${NASDIR} > foo.out 2> foo.err < /dev/null &
    # Allow user logins
    $SSH_1S "$RAC infobase --cluster=$CLUSTER update --infobase=$BASEID --infobase-user=\"$IBUSER\" \
        --infobase-pwd=\"$IBPWD\" --denied-from=\"\" --denied-to=\"\" --sessions-deny=off \
        --scheduled-jobs-deny=off --permission-code=\"\" --denied-message=\"\" \
        --cluster-user=$CLSTR_USER --cluster-pwd='$CLSTR_PWD'"
    # Remove expired dumps from NAS
    for FILE in `$SSH_NAS "find ${NASDIR} -iname \"${BASE}*\""`; do
        FILESTAMP=`echo $FILE | sed -E 's/.*_stamp([0-9]+).*/\1/'`
        DIFF=$(expr ${STAMP} - ${FILESTAMP})
        if [[ "$DIFF" -gt "$MAXAGE" ]]; then
            $SSH_NAS "rm -f $FILE"
        fi
    done
done
