#!/bin/bash

TMPDIR="/tmp"
RUN_INSTALLER=true
DOWNLOAD=true
export BATCH=1

while getopts ":dr" opt; do
  case $opt in
    d)
        RUN_INSTALLER=false
        DOWNLOAD=true
        ;;
    r)
        RUN_INSTALLER=true
        DOWNLOAD=false
        ;;
    \?)
      echo "Ungültige Option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Die Option -$OPTARG erfordert ein Argument." >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
FIRSTDIR=${PWD}

# getting latest anaconda version
latest_script=$(curl -s -L https://repo.anaconda.com/archive/ | grep -oP 'Anaconda[0-9]*-\d{4}\.\d{2}-\d+-Linux-x86_64.sh' | sort -rV | head -n 1)

if [ "$DOWNLOAD" = true ]; then
  # download the client
  cd ${TMPDIR}
  wget -O anaconda.sh --content-disposition https://repo.anaconda.com/archive/${latest_script}
  sed -i 's/BATCH=0/BATCH=1/' "${TMPDIR}/anaconda.sh"
fi

if [ "$RUN_INSTALLER" = true ]; then
  cd ${TMPDIR}
  bash ${TMPDIR}/anaconda.sh
fi

# Zurück zum ursprünglichen Verzeichnis
cd ${FIRSTDIR}

exit 0