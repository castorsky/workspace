#!/bin/bash
PARTLABEL="BACKUPS" # label of backup partition
BACKDIR="system" # directory in backup partition
MAXAGE="14" # days
SNAPSHOTS="/.snapshots" # target for temporary snapshots
DATE="$(date +%Y-%m-%d_%H:%M)"

# Find mounted backup partition and die if not found
BACKUP_MPOINT=$(grep `blkid | grep '"BACKUPS"' | awk -F ':' '{print $1}'` /etc/mtab | awk '{print $2}')
if [ -z $BACKUP_MPOINT ]; then
    echo "Backup partition \"$PARTLABEL\" is not mounted. Stopped."
    exit 1
fi

# Create directory for new backup
BACKDIR="$BACKUP_MPOINT/$BACKDIR"
mkdir -p "$BACKDIR/$DATE"

# List backup directories in target and remove older than MAXAGE days
find "$BACKDIR" -regextype egrep -regex '.*[0-9]{4}-[0-9]{2}-[0-9]{2}.*' | while read DIRNAME; do
    DIRDATE=$(date -d "$(basename $DIRNAME | sed 's/_/ /')" +%s)
    OLDDATE=$(date -d "$MAXAGE days ago" +%s)
    if [ $DIRDATE -le $OLDDATE ]; then
        # Remove old backups
        echo "Backup $DIRDATE older than $MAXAGE days. Deleted."
        rm -rf $DIRNAME
    fi
done

# make_snapshot(subvolume_path subvolume_backup_name)
make_snapshot() {
    VOL_PATH=$1
    VOL_NAME=$2
    SNAP=$(btrfs subvolume snapshot -r $VOL_PATH ${SNAPSHOTS}/backup-$VOL_NAME)
}

# delete_snapshot(subvolume_backup_name)
delete_snapshot() {
    VOL_NAME=$1
    SNAP=$(btrfs subvolume delete -C ${SNAPSHOTS}/backup-$VOL_NAME)
}

# do_backup(subvolume_path subvolume_backup_name)
do_backup() {
    VOL_PATH=$1
    VOL_NAME=$2
    make_snapshot $VOL_PATH $VOL_NAME
    cd "${SNAPSHOTS}/backup-$VOL_NAME"
    tar -c -p -I zstd -f "${BACKDIR}/${DATE}/${VOL_NAME}.tar.zst" . >/dev/null 2>&1
    cd - >/dev/null 2>&1
    delete_snapshot $VOL_NAME
}

# Make / backup at first place
do_backup "/" "rootfs"
# Then traverse all subvolumes and make backup of each
VOL_LIST=$(btrfs subvolume list / | grep -v snapshot | awk '{print $9}' | sed -e 's/^@//')
for VOL in $VOL_LIST
do
    VOLNAME=$(echo $VOL | sed -e 's/\///g')
    do_backup $VOL $VOLNAME
done
