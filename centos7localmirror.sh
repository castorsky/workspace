#!/bin/bash
if [ -d /data/localmirror/centos/7.0.1406 ] ; then
    rsync  -avSHP --delete --exclude "local*" --exclude "isos" mirror.yandex.ru::centos/7.0.1406/ /data/localmirror/centos/7.0.1406/
else
    echo "Target directory /data/localmirror/centos/7.0.1406 not present."
fi
if [ -d /data/localmirror/elrepo ] ; then
    rsync  -avSHP --delete --exclude "*/el5/*" --exclude "*/el6/*" --exclude "*/i386/*" elrepo.reloumirrors.net::elrepo/ /data/localmirror/elrepo/
else
    echo "Target directory /data/localmirror/elrepo not present."
fi
if [ -d /data/localmirror/epel/7/x86_64 ] ; then
    rsync  -avSHP --delete mirror.logol.ru::epel/7/x86_64/ /data/localmirror/epel/7/x86_64/
else
    echo "Target directory /data/localmirror/epel/7/x86_64 not present."
fi
