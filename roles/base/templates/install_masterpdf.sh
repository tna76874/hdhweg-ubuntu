#!/bin/bash
VERSION=$(curl -s -L https://code-industry.net/checksum-information/ |  grep qt5.x86_64.deb | awk '/master-pdf-editor-/,/-qt5.x86_64.deb/' | awk -v FS="(master-pdf-editor-|-qt5.x86_64.deb)" '{print $2}')
DEB=master-pdf-editor-"$VERSION"-qt5.x86_64.deb

AVAILABLE=$(echo ${VERSION} | awk -F- '{print $1}')
INSTALLED=$(dpkg -l | grep master-pdf-editor | tr -s ' ' | tr -s ' ' | cut -d" " -f3)

if [ "$AVAILABLE" != "$INSTALLED" ]
then
  cd /tmp
  wget https://code-industry.net/public/$DEB
  sudo dpkg -i "$DEB"
  sudo rm "$DEB"
fi

