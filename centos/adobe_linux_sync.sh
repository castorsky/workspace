#!/bin/bash

BASE_DIR="/srv/localmirror"
ADOBE_REPOS="adobe-linux-i386 adobe-linux-x86_64"
ADOBE_DIR="${BASE_DIR}/adobe"

for REPO in ${ADOBE_REPOS}; do
    if [ -d "${ADOBE_DIR}/${REPO}" ]; then
        reposync --repoid=${REPO} -p ${ADOBE_DIR}
        createrepo "${ADOBE_DIR}/${REPO}"
    else
        echo "Target directory ${ADOBE_DIR}/${REPO} does not exist."
    fi
done
