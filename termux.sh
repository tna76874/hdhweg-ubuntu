#!/bin/bash
DEBIAN_FRONTEND=noninteractive

# termux-change-repo
echo -e | pkg upgrade -y
echo -e | pkg update -y
echo -e | pkg install openssh rsync autossh -y

curl -o ~/.ssh/authorized_keys https://github.com/tna76874.keys

sed -i 's/^PasswordAuthentication yes$/PasswordAuthentication no/' $PREFIX/etc/ssh/sshd_config

termux-setup-storage
