#!/bin/bash
VERSION=$(curl -s -L https://code-industry.net/checksum-information/ |  grep all.amd64.deb | awk '/master-pdf-editor-/,/amd64.deb/' | awk -v FS="(master-pdf-editor-|.amd64.deb)" '{print $2}')
DEB=master-pdf-editor-"$VERSION".amd64.deb

AVAILABLE=$(echo ${VERSION} | awk -F- '{print $1}')
INSTALLED=$(dpkg -s master-pdf-editor | grep '^Version:' | awk '{print $2}')

if [ $AVAILABLE != $INSTALLED ]
then
  cd /tmp
  wget https://code-industry.net/public/$DEB
  sudo dpkg -i "$DEB"
  sudo rm "$DEB"
fi

