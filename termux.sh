#!/bin/bash
DEBIAN_FRONTEND=noninteractive

function run_until_success {
    while true; do
        echo -e | pkg upgrade -y
        if [ $? -eq 0 ]; then
            break 
        fi
    done
    while true; do
        echo -e | pkg update -y
        if [ $? -eq 0 ]; then
            break 
        fi
    done
    while true; do
        echo -e | pkg install openssh rsync autossh -y
        if [ $? -eq 0 ]; then
            break 
        fi
    done
}

run_until_success

curl -o ~/.ssh/authorized_keys https://github.com/tna76874.keys

sed -i 's/^PasswordAuthentication yes$/PasswordAuthentication no/' $PREFIX/etc/ssh/sshd_config

termux-setup-storage
