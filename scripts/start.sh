#! /bin/bash

sudo service mysql start
sudo service redis-server start

host_ip="$(tail -1 /etc/resolv.conf | cut -d' ' -f2)"

for dir in "/etc/php/"* ; do
    version=$(basename "$dir")
    echo " * Starting PHP FPM ${version}";
    sudo sed -i "s/xdebug.client_host = .*/xdebug.client_host = ${host_ip}/" "/etc/php/${version}/mods-available/xdebug.ini"
    sudo sed -i "s/xdebug.remote_host = .*/xdebug.remote_host = ${host_ip}/" "/etc/php/${version}/mods-available/xdebug.ini"
    sudo service php"$version"-fpm start
done

sudo service supervisor start
sudo service apache2 start
