#!/bin/bash
CENTOS_RELEASE="6.6"
BASE_DIR="/var/calculate/server-data/samba/share/soft/localmirror"

if [ -d ${BASE_DIR}/centos/${CENTOS_RELEASE} ] ; then
  rsync -avSHP --delete --exclude "SCL" --exclude "cr" --exclude "xen4" --exclude "isos" mirror.yandex.ru::centos/${CENTOS_RELEASE}/ ${BASE_DIR}/centos/${CENTOS_RELEASE}/
else
  echo "Target directory ${BASE_DIR}/centos/${CENTOS_RELEASE} not present."
fi

if [ -d ${BASE_DIR}/elrepo ] ; then
  rsync -avSHP --delete --exclude "*/el5/*" --exclude "*/el7/*" elrepo.reloumirrors.net::elrepo/ ${BASE_DIR}/elrepo/
else
  echo "Target directory ${BASE_DIR}/elrepo not present."
fi

if [ -d ${BASE_DIR}/epel/6 ] ; then
  rsync -avSHP --delete --exclude "SRPMS" --exclude "ppc64" --exclude "*/debug/*" mirror.logol.ru::epel/6/ ${BASE_DIR}/epel/6/
else
  echo "Target directory ${BASE_DIR}/epel/6 not present."
fi
