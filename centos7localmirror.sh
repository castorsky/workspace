#!/bin/bash
CENTOS_RELEASE="6.6"
if [ -d /data/localmirror/centos/${CENTOS_RELEASE} ] ; then
    rsync  -avSHP --delete --exclude "SCL" --exclude "cr" --exclude "xen4" --exclude "isos" mirror.yandex.ru::centos/${CENTOS_RELEASE}/ /data/localmirror/centos/${CENTOS_RELEASE}/
else
    echo "Target directory /data/localmirror/centos/${CENTOS_RELEASE} not present."
fi
if [ -d /data/localmirror/elrepo ] ; then
    rsync  -avSHP --delete --exclude "*/el5/*" --exclude "*/el7/*" elrepo.reloumirrors.net::elrepo/ /data/localmirror/elrepo/
else
    echo "Target directory /data/localmirror/elrepo not present."
fi
if [ -d /data/localmirror/epel/6 ] ; then
    rsync  -avSHP --delete mirror.logol.ru::epel/6/ /data/localmirror/epel/6/
else
    echo "Target directory /data/localmirror/epel/6 not present."
fi
