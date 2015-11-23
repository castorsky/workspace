#!/bin/bash
CENTOS_RELEASE="7"
ELREPO_EXCLUDE_RELEASE="6"
EPEL_RELEASE="7"
BASE_DIR="/srv/localmirror"
NUX_RELEASE="el7"

if [ -d ${BASE_DIR}/centos/${CENTOS_RELEASE} ] ; then
  rsync -avSHP --delete --exclude "isos" mirror.yandex.ru::centos/${CENTOS_RELEASE}/ ${BASE_DIR}/centos/${CENTOS_RELEASE}/
else
  echo "Target directory ${BASE_DIR}/centos/${CENTOS_RELEASE} not present."
fi

if [ -d ${BASE_DIR}/elrepo ] ; then
  rsync -avSHP --delete --exclude "*/el5/*" --exclude "*/el${ELREPO_EXCLUDE_RELEASE}/*" elrepo.reloumirrors.net::elrepo/ ${BASE_DIR}/elrepo/
else
  echo "Target directory ${BASE_DIR}/elrepo not present."
fi

if [ -d ${BASE_DIR}/epel/${EPEL_RELEASE} ] ; then
  rsync -avSHP --delete --exclude "SRPMS" --exclude "ppc64" --exclude "*/debug/*" mirror.logol.ru::epel/${EPEL_RELEASE}/ ${BASE_DIR}/epel/${EPEL_RELEASE}/
else
  echo "Target directory ${BASE_DIR}/epel/${EPEL_RELEASE} not present."
fi

if [ -d ${BASE_DIR}/nux/dextop/${NUX_RELEASE} ] ; then
  rsync -avSHP --delete --exclude "SRPMS" --exclude "tmp" li.nux.ro::li.nux.ro/nux/dextop/${NUX_RELEASE}/ ${BASE_DIR}/nux/dextop/${NUX_RELEASE}
else
  echo "Target firectory ${BASE_DIR}/nux/dextop/${NUX_RELEASE} not present."
