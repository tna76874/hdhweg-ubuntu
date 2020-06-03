#!/bin/bash
# setting the location of the ansible playbook repository
REPODIR="/root/hdhweg-ubuntu"

# delete the repository, if present. 
rm -rf ${REPODIR}

# update system sources and install ansible and git.
sudo apt update
sudo apt install software-properties-common -y
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt update
sudo apt install git ansible -y

# clone the playbook repository
git clone https://github.com/tna76874/hdhweg-ubuntu.git ${REPODIR}

# run the playbook to set up the system
cd ${REPODIR}
sudo ansible-playbook ${1-setup.yml}
