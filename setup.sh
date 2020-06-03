#!/bin/bash

REPODIR="/root/hdhweg-ubuntu"

sudo apt update
sudo apt install software-properties-common -y
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt update
sudo apt install git ansible -y

git clone https://github.com/tna76874/hdhweg-ubuntu.git ${REPODIR}
cd ${REPODIR}

sudo ansible-playbook main.yml
