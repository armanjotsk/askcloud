#!/bin/bash
# setup_ssh.sh

echo "Configurando entorno local..."

# 1. Mover bastion key
if [ -f "bastion.pem" ]; then
    mv bastion.pem ~/.ssh/
    chmod 400 ~/.ssh/bastion.pem
fi

# 2. Mover private keys
for f in private-*.pem; do
    if [ -e "$f" ]; then
        mv "$f" ~/.ssh/
        chmod 400 ~/.ssh/"$f"
    fi
done

# 3. Añadir configuración
if [ -f "ssh_config_per_connect.txt" ]; then
    cat ssh_config_per_connect.txt >> ~/.ssh/config
    echo "Configuración SSH actualizada."
fi