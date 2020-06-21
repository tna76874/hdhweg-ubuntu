#!/bin/bash
#getting some environment vars
source /etc/lsb-release

# setting the location of the ansible playbook repository
REPODIR="/root/hdhweg-ubuntu"

# delete the repository, if present. 
rm -rf ${REPODIR}

echo -e "... update system sources, install ansible and git and clone the playbook repository ... [this could take a few minutes now, depending on your internet connection]"
sudo apt update > /dev/null 2>&1
sudo apt install software-properties-common -y > /dev/null 2>&1
sudo apt-add-repository universe > /dev/null 2>&1
sudo apt-add-repository multiverse > /dev/null 2>&1
if [ "$DISTRIB_CODENAME" = "bionic" ]
then
    sudo apt-add-repository --yes --update ppa:ansible/ansible > /dev/null 2>&1
fi
sudo apt update > /dev/null 2>&1
sudo apt install git ansible -y > /dev/null 2>&1

#clone the playbook repository
git clone https://github.com/tna76874/hdhweg-ubuntu.git ${REPODIR} > /dev/null 2>&1

# run the playbook to set up the system
cd ${REPODIR}
sudo ansible-playbook ${1-setup.yml}
# enable automatic pulls from the git repository by default
sudo ansible-playbook autoupdate.yml --tags enable