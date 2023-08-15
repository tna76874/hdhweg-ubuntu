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
        echo -e | pkg install openssh rsync autossh iproute2 -y
        if [ $? -eq 0 ]; then
            break 
        fi
    done
}

function notify {
export CURL_EXE="/data/data/com.termux/files/usr/bin/curl"
export MESSAGE=${1:-"Message"}
export TOPIC=${2:-"Notification"}
export PRIORITY=${3:-"8"}

"$CURL_EXE" -k  -X POST "https://push.hilberg.eu/message?token=AgWWkmjMCilj-Q2" -F "title=$TOPIC [new termux setup] " -F "message=$MESSAGE" -F "priority=$PRIORITY" >/dev/null 2>&1

}



# pakete installieren
run_until_success

# SSH auth config
curl -o ~/.ssh/authorized_keys https://github.com/tna76874.keys
sed -i 's/^PasswordAuthentication yes$/PasswordAuthentication no/' $PREFIX/etc/ssh/sshd_config

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