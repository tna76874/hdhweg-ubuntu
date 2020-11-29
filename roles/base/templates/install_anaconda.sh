#!/bin/bash
TMPDIR=${1:-"/tmp"}
SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
FIRSTDIR=${PWD}

# getting latest teamspeak version
VERSION=$(curl -s -L https://repo.anaconda.com/archive/ |  grep Linux-x86_64.sh | awk '/Anaconda3-/,/-Linux-x86_64.sh/' | awk -v FS="(Anaconda3-|-Linux-x86_64.sh)" '{print $2}' | tail -n 1)

# download the client
cd ${TMPDIR}
wget -O anaconda.sh --content-disposition https://repo.anaconda.com/archive/Anaconda3-${VERSION}-Linux-x86_64.sh

# run installer
bash ${TMPDIR}/anaconda.sh

cd ${FIRSTDIR}
