#!/usr/bin/env bash

# Remove the orchard block
# sudo sed -i '/^### orchard hosts/,/^### end orchard hosts/d' /mnt/c/Windows/System32/drivers/etc/hosts

# Uncomment if you want orchard to add hosts to your windows host file for you (needs WSL2 to be executed as administrator)
# echo "127.0.0.1 " $1 >> /mnt/c/Windows/System32/drivers/etc/hosts
