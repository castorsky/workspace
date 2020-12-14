#!/bin/sh
CPBIN=/opt/cprocsp/bin/amd64
CPSBIN=/opt/cprocsp/sbin/amd64
if [ -d $CPBIN ] && ( ! echo ${PATH} | /bin/grep -q $CPBIN ) ; then
    PATH=$PATH:$CPBIN
fi
if [ -d "$CPSBIN" ] && ( ! echo ${PATH} | /bin/grep -q $CPSBIN ) ; then
    PATH=$PATH:$CPSBIN
fi
export PATH
