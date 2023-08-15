#!/bin/bash
DEBIAN_FRONTEND=noninteractive

# termux-change-repo
pkg upgrade -y
#pkg update -y
#pkg install openssh rsync autossh -y
echo '\n' | pkg install openssh -y

curl -o ~/.ssh/authorized_keys https://github.com/tna76874.keys

sed -i 's/^PasswordAuthentication yes$/PasswordAuthentication no/' $PREFIX/etc/ssh/sshd_config

termux-setup-storage
