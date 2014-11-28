#!/bin/bash
if [ -d /data/localmirror/centos/7.0.1406 ] ; then
    rsync  -avSHP --delete --exclude "local*" --exclude "isos" mirror.yandex.ru::centos/7.0.1406/ /data/localmirror/centos/7.0.1406/
else
    echo "Target directory /data/localmirror/centos/7.0.1406 not present."
fi
