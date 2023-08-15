#!/bin/bash

pkg upgrade
pkg install openssh rsync autossh -y

curl -o ~/.ssh/authorized_keys https://github.com/tna76874.keys

sed -i 's/^PasswordAuthentication yes$/PasswordAuthentication no/' $PREFIX/etc/ssh/sshd_config

termux-setup-storage
