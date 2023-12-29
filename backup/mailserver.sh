#!/usr/bin/bash

SSH_OPTS="/usr/bin/ssh -l root -i /root/.ssh/mail-backup -o StrictHostKeyChecking=no"
HOST="mail.server.example.org"
FS="backpool/mailserver"
MP=`zfs get mountpoint -H ${FS} | awk '{print $3}'`
DATE=`date +%s`
DATE_STR=`TZ=UTC date '+%Y-%m-%d_%H:%M:%S'`
MAX_DAYS=14
MAX_AGE=$((3600*24*${MAX_DAYS}))
SOURCES=(
    "/opt"
    "/etc"
    "/var/.snapshots/backup/lib/containers/volumes"
)

function _cleanup {
    # Clean up snapshots older than $MAX_DAYS
    SNAPS=`zfs list -t snapshot -H -o name ${FS} | sed -E 's/.*?@pre_//'`
    for SNAP in ${SNAPS}; do
        SNAP_SP=`echo ${SNAP} | sed 's/_/ /'`
        EPOCH=`date -d "${SNAP_SP}" '+%s'`
        if [[ $(($DATE-$EPOCH)) -ge ${MAX_AGE} ]]; then
            zfs destroy "${FS}@${SNAP}"
        fi
    done
}

function _prepare_remote {
    CREATE_SNAP_CHAIN='SNAP_VOL_EXISTS=$(btrfs subvolume list /var | grep "\.snapshots" | wc -l);
    if [[ ${SNAP_VOL_EXISTS} != "1" ]]; then btrfs subvolume create /var/.snapshots; fi;
    btrfs subvolume snapshot -r /var /var/.snapshots/backup'

    $SSH_OPTS root@$HOST $CREATE_SNAP_CHAIN
}

function _clean_remote {
    REMOVE_SNAP_CHAIN='SNAP_VOL_EXISTS=$(btrfs subvolume list /var | grep "\.snapshots/backup" | wc -l);
    if [[ ${SNAP_VOL_EXISTS} == "1" ]]; then btrfs subvolume delete /var/.snapshots/backup; fi;'

    $SSH_OPTS root@$HOST $REMOVE_SNAP_CHAIN
}


function _backup {
    # Take fresh snapshot and make backup
    zfs snapshot "${FS}@pre_${DATE_STR}"
    for I in "${!SOURCES[@]}"; do
        echo "Copying ${SOURCES[$I]} to ${MP}..."
        CMD="rsync -az --delete -e \"$SSH_OPTS\" root@${HOST}:${SOURCES[$I]} ${MP}/"
        eval "$CMD"
        echo "Successful: ${SOURCES[$I]}"
    done
}

_prepare_remote
_backup
_clean_remote
_cleanup
