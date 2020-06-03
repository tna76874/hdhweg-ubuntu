#!/bin/bash
VERSION=$(curl -s -L https://code-industry.net/checksum-information/ |  grep all.amd64.deb | awk '/master-pdf-editor-/,/amd64.deb/' | awk -v FS="(master-pdf-editor-|.amd64.deb)" '{print $2}')
DEB=master-pdf-editor-"$VERSION".amd64.deb

cd ~/Downloads
wget https://code-industry.net/public/$DEB

sudo dpkg -i "$DEB"
sudo rm "$DEB"
