#!/bin/bash

BASE_DIR="/srv/localmirror"
ADOBE_REPOS="adobe-linux-i386 adobe-linux-x86_64"
ADOBE_DIR="${BASE_DIR}/adobe"
SERNET_REPO="samba-4.1"
SERNET_DIR="${BASE_DIR}/sernet"

for REPO in ${ADOBE_REPOS}; do
    if [ -d "${ADOBE_DIR}/${REPO}" ]; then
        reposync --repoid=${REPO} -p ${ADOBE_DIR}
        createrepo "${ADOBE_DIR}/${REPO}"
    else
        echo "Target directory ${ADOBE_DIR}/${REPO} does not exist."
    fi
done

if [ -d "${SERNET_DIR}" ]; then
    reposync --repoid=${SERNET_REPO} -p ${SERNET_DIR}
    createrepo "${SERNET_DIR}/${SERNET_REPO}"
else
    echo "Target directory ${SERNET_DIR} does not exist."
