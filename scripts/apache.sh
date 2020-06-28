#!/usr/bin/env bash

declare domain=$1
declare path=$2
declare php_version=$3
declare http_port="80"
declare https_port="443"

block="<VirtualHost *:$http_port>
    ServerAdmin webmaster@localhost
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot $path

    <Directory $path>
        AllowOverride All
        Require all granted
    </Directory>

    <IfModule mod_proxy_fcgi.c>
        <FilesMatch \".+\.ph(ar|p|tml)$\">
            SetHandler \"proxy:unix:/run/php/php$php_version-fpm.sock|fcgi://localhost\"
        </FilesMatch>
    </IfModule>

    ErrorLog \${APACHE_LOG_DIR}/$domain-error.log
    CustomLog \${APACHE_LOG_DIR}/$domain-access.log combined

</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
"

echo "$block" > "/etc/apache2/sites-available/$domain.conf"
sudo a2ensite "$domain.conf"

blockssl="<IfModule mod_ssl.c>
    <VirtualHost *:$https_port>

        ServerAdmin webmaster@localhost
        ServerName $domain
        ServerAlias www.$domain
        DocumentRoot $path

        <Directory $path>
            AllowOverride All
            Require all granted
        </Directory>

        ErrorLog \${APACHE_LOG_DIR}/$domain-error.log
        CustomLog \${APACHE_LOG_DIR}/$domain-access.log combined

        SSLEngine on
        SSLCertificateFile      /etc/apache2/ssl/$domain.crt
        SSLCertificateKeyFile   /etc/apache2/ssl/$domain.key

        <FilesMatch \"\.(cgi|shtml|phtml|php)$\">
            SSLOptions +StdEnvVars
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
            SSLOptions +StdEnvVars
        </Directory>

        <IfModule mod_proxy_fcgi.c>
            <FilesMatch \".+\.ph(ar|p|tml)$\">
                SetHandler \"proxy:unix:/run/php/php$php_version-fpm.sock|fcgi://localhost/\"
            </FilesMatch>
        </IfModule>
    </VirtualHost>
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
"

echo "$blockssl" > "/etc/apache2/sites-available/$domain-ssl.conf"
sudo a2ensite "$domain-ssl.conf"

ps auxw | grep apache2 | grep -v grep > /dev/null

# Enable FPM
sudo a2enconf php"$php_version"-fpm
# Assume user wants mode_rewrite support
sudo a2enmod rewrite

# Turn on HTTPS support
sudo a2enmod ssl

# Turn on proxy & fcgi
sudo a2enmod proxy proxy_fcgi

# Turn on headers support
sudo a2enmod headers actions alias

# Add Mutex to config to prevent auto restart issues
if [ -z "$(grep '^Mutex posixsem$' /etc/apache2/apache2.conf)" ]
then
    echo 'Mutex posixsem' | sudo tee -a /etc/apache2/apache2.conf
fi

# create socket directory
mkdir -p /run/php

service apache2 restart
service php"$php_version"-fpm restart
