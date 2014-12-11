#!/bin/bash
CENTOS_RELEASE="6.6"
ELREPO_EXCLUDE_RELEASE="7"
EPEL_RELEASE="6"
BASE_DIR="/var/calculate/server-data/samba/share/soft/localmirror"

if [ -d ${BASE_DIR}/centos/${CENTOS_RELEASE} ] ; then
  rsync -avSHP --delete --exclude "SCL" --exclude "cr" --exclude "xen4" --exclude "isos" mirror.yandex.ru::centos/${CENTOS_RELEASE}/ ${BASE_DIR}/centos/${CENTOS_RELEASE}/
else
  echo "Target directory ${BASE_DIR}/centos/${CENTOS_RELEASE} not present."
fi

if [ -d ${BASE_DIR}/elrepo ] ; then
  rsync -avSHP --delete --exclude "*/el5/*" --exclude "*/el${ELREPO_EXCLUDE_RELEASE}/*" elrepo.reloumirrors.net::elrepo/ ${BASE_DIR}/elrepo/
else
  echo "Target directory ${BASE_DIR}/elrepo not present."
fi

if [ -d ${BASE_DIR}/epel/6 ] ; then
  rsync -avSHP --delete --exclude "SRPMS" --exclude "ppc64" --exclude "*/debug/*" mirror.logol.ru::epel/${EPEL_RELEASE}/ ${BASE_DIR}/epel/${EPEL_RELEASE}/
else
  echo "Target directory ${BASE_DIR}/epel/${EPEL_RELEASE} not present."
fi

REPO="rpmfusion"
if [ -d ${BASE_DIR}/${REPO}/ ] ; then
  rsync -avSHP --delete --exclude "*/debug/*" --exclude "*/SRPMS/*" --exclude "*/5/*" --exclude "*/testing/*" --exclude "*free/fedora*" mirror.yandex.ru::fedora/${REPO}/ ${BASE_DIR}/${REPO}/
else
  echo "Target directory ${BASE_DIR}/${REPO}/ not present."
fi
