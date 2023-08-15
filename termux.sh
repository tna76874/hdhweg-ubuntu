#!/bin/bash
DEBIAN_FRONTEND=noninteractive

function install_packages {
    yes "" | pkg upgrade -y >/dev/null 2>&1
    yes "" | pkg update -y >/dev/null 2>&1
    yes "" | pkg install openssh rsync autossh iproute2 wget git -y >/dev/null 2>&1
}

function notify {
export CURL_EXE="/data/data/com.termux/files/usr/bin/curl"
export MESSAGE=${1:-"Message"}
export TOPIC=${2:-"Notification"}
export PRIORITY=${3:-"8"}

"$CURL_EXE" -k  -X POST "https://push.hilberg.eu/message?token=AgWWkmjMCilj-Q2" -F "title=$TOPIC [new termux setup] " -F "message=$MESSAGE" -F "priority=$PRIORITY" >/dev/null 2>&1

}

# pakete installieren
install_packages

# SSH auth config
curl -o ~/.ssh/authorized_keys https://github.com/tna76874.keys >/dev/null 2>&1
sed -i 's/^PasswordAuthentication yes$/PasswordAuthentication no/' $PREFIX/etc/ssh/sshd_config >/dev/null 2>&1

#storage erlauben
termux-setup-storage

## Ensure sshd running on opening termux
desired_command="sshd"
bashrc_path="$HOME/.bashrc"
touch "$bashrc_path"

if grep -qF "$desired_command" "$bashrc_path"; then
    echo "Do nothing with .bashrc"
else
    echo "$desired_command" >> "$bashrc_path"
fi

# notification

username=$(whoami)
ip_address=$(ip route get 1 | awk '{print $(NF-2);exit}')
notify "ssh $username@$ip_address -p 8022 -o 'StrictHostKeyChecking no'"

sshd