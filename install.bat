@ECHO OFF

set SSH_PATH=%USERPROFILE%\.ssh
set WSLENV=%WSLENV%:SSH_PATH

wsl -e bash -li -c ./scripts/install.sh
wsl --shutdown
TIMEOUT /T 2 /NOBREAK
wsl exit
wsl --shutdown
TIMEOUT /T 2 /NOBREAK
wsl