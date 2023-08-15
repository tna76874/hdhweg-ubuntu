#!/bin/bash
DEBIAN_FRONTEND=noninteractive

function run_command_until_success {
    command="$1"  # Das übergebene Kommando als erster Parameter

    while true; do
        # Führe das übergebene Kommando aus
        $command

        
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
run_command_until_success "echo -e | pkg upgrade -y"
run_command_until_success "echo -e | pkg update -y"
run_command_until_success "echo -e | pkg install openssh rsync autossh -y"      

curl -o ~/.ssh/authorized_keys https://github.com/tna76874.keys

sed -i 's/^PasswordAuthentication yes$/PasswordAuthentication no/' $PREFIX/etc/ssh/sshd_config

termux-setup-storage
