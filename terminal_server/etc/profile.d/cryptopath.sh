#!/bin/sh
CPBIN=/opt/cprocsp/bin/amd64
CPSBIN=/opt/cprocsp/sbin/amd64
if [ -d "$CPBIN" ]; then
    PATH=$PATH:$CPBIN
fi
if [ -d "$CPSBIN" ]; then
    PATH=$PATH:$CPSBIN
fi
export PATH
