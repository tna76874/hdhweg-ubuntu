#!/bin/bash

# 1. Root check
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (use sudo)."
   exit 1
fi

set -e
export DEBIAN_FRONTEND=noninteractive

REPODIR="/root/hdhweg-ubuntu"
rm -rf "${REPODIR}"

echo -e "\n[1/4] Preparing system sources..."
# Use -qq for apt to keep it quiet but allow critical errors to show
apt-get update -qq
apt-get install -y -qq software-properties-common > /dev/null

echo "[2/4] Adding software repositories..."
apt-add-repository -y universe > /dev/null
apt-add-repository -y multiverse > /dev/null
apt-add-repository --yes --update ppa:ansible/ansible > /dev/null

echo "[3/4] Installing Ansible and Git..."
apt-get install -y -qq git ansible > /dev/null

echo "[4/4] Downloading and running configuration..."
git clone https://github.com/tna76874/ubuntu-desktop.git "${REPODIR}" --quiet
cd "${REPODIR}"

# Running the playbook
# We don't silence this completely so the user sees the final progress
ansible-playbook main.yml -t "${1-setup}"