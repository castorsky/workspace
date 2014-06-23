#!/bin/sh

# This script used to check IrGUPS OpenVPN connection

# Which script is used to start/stop connection
APP="/usr/local/etc/rc.d/openvpn_irgups"
SERVER="172.16.2.12"

# Does this script have to check connection
# By default ENABLE = 0. If OpenVPN is enabled in rc.conf, then ENABLE = 1
ENABLE="0"

log() {
    /usr/bin/logger -t checkinet "$@"
#    echo "$@"
}

[ -s /etc/rc.conf ] && ENABLE=`cat /etc/rc.conf | grep -c 'openvpn_irgups_enable="YES"'`

if [ "$ENABLE" = "1" ]
then
#    log "OpenVPN daemon enabled. Start checking inet connection."
    COUNT=`ping -c3 "$SERVER" | grep -c "icmp_seq="`
    if [ "$COUNT" = "0" ]
    then
        log "No echo replies from $SERVER. Restart connection."
        $APP restart
    else
        log "Echo replies from $SERVER were received. No restart required."
    fi
else
    log "OpenVPN daemon not enabled. Nothing to do."
    exit 1
fi
exit 0
