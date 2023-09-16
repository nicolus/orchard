#!/usr/bin/env bash

me=$(whoami)
echo "Hello $me, we'll now ask you for sudo permission to install stuff"

sudo bash ./scripts/provision-ubuntu.sh ${me}

echo "Installation finished !"
