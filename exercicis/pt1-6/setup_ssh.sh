#!/bin/bash
# setup_ssh.sh

# Mover claves
mv bastion.pem ~/.ssh/
mv private-*.pem ~/.ssh/

# Permisos
chmod 400 ~/.ssh/bastion.pem
chmod 400 ~/.ssh/private-*.pem

# Config
cat ssh_config_per_connect.txt >> ~/.ssh/config