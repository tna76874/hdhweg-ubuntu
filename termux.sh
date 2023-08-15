#!/bin/bash
DEBIAN_FRONTEND=noninteractive

function run_until_success {
    while true; do
        echo -e | pkg upgrade -y
        echo -e | pkg update -y
        echo -e | pkg install openssh rsync autossh -y
        
        # Überprüfe den Exit-Code des Befehls
        if [ $? -eq 0 ]; then
            echo "Befehl erfolgreich ausgeführt."
            break 
        else
            echo "Befehl fehlgeschlagen. Erneuter Versuch..."
        fi
    done
}

# Rufe die Funktion auf
run_until_success

curl -o ~/.ssh/authorized_keys https://github.com/tna76874.keys

sed -i 's/^PasswordAuthentication yes$/PasswordAuthentication no/' $PREFIX/etc/ssh/sshd_config

termux-setup-storage
