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

    <FilesMatch \".+\.php$\">
        SetHandler \"proxy:unix:/run/php/php$php_version-fpm.sock|fcgi://localhost\"
    </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/$domain-error.log
    CustomLog \${APACHE_LOG_DIR}/$domain-access.log combined
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
"



blockssl="<VirtualHost *:$https_port>
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

  <FilesMatch \".+\.php$\">
    SetHandler \"proxy:unix:/run/php/php$php_version-fpm.sock|fcgi://localhost/\"
  </FilesMatch>
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
"

echo "$block" > "/etc/apache2/sites-available/$domain.conf"
echo "$blockssl" > "/etc/apache2/sites-available/$domain-ssl.conf"

sudo a2ensite "$domain-ssl.conf"
sudo a2ensite "$domain.conf"

service apache2 restart
service php"$php_version"-fpm restart
