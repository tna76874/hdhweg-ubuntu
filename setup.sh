#!/bin/bash

REPODIR="/root/hdhweg-ubuntu"

sudo apt update
sudo apt install software-properties-common python-software-properties -y
sudo add-apt-repository universe
sudo apt-add-repository multiverse
sudo apt update
sudo apt install git ansible -y

git clone git@github.com:tna76874/hdhweg-ubuntu.git ${REPODIR}
cd ${REPODIR}

sudo ansible-playbook main.yml
