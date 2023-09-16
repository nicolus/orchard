#!/usr/bin/env bash

me=$(whoami)
echo "Hello $me, we'll now ask you for sudo permission to install stuff $SSH_PATH"

sudo SSH_PATH="$SSH_PATH" bash ./scripts/provision-ubuntu.sh ${me}

echo "Installation finished !"
