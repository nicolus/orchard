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

<VirtualHost *:$https_port>
  ServerAdmin webmaster@localhost
  ServerName $domain
  ServerAlias www.$domain
  DocumentRoot $path

  <Directory $path>
    AllowOverride All
    Require all granted
  </Directory>

  <FilesMatch \".+\.php$\">
    SSLOptions +StdEnvVars
    SetHandler \"proxy:unix:/run/php/php$php_version-fpm.sock|fcgi://localhost/\"
  </FilesMatch>

  ErrorLog \${APACHE_LOG_DIR}/$domain-error.log
  CustomLog \${APACHE_LOG_DIR}/$domain-access.log combined

  SSLEngine on
  SSLCertificateFile      /etc/apache2/ssl/$domain.crt
  SSLCertificateKeyFile   /etc/apache2/ssl/$domain.key
</VirtualHost>
"

echo "$block" > "/etc/apache2/sites-available/$domain.conf"

sudo a2ensite "$domain.conf"

# restart apache2 to take the new configurations into account
service apache2 reload

# Restart php-fpm ("restart" gives a failure if it was not started, this way looks better in the logs)
service php"$php_version"-fpm stop
service php"$php_version"-fpm start

echo -e " \033[0;32m\xE2\x9C\x94 Domain \033[0;34m$domain\033[0;32m is now up !\033[0m"

WINHOSTSFILE="/mnt/c/Windows/System32/drivers/etc/hosts";
if test -f "$WINHOSTSFILE"; then
  if ! grep -qE "^[[:space:]]*127.0.0.1[[:space:]]+$domain" $WINHOSTSFILE; then
    echo -e "\033[0;33mThis domain was not found in your Windows hosts file, you will need to add these lines to access the site :\033[0m"
    echo "127.0.0.1 $domain"
    echo "::1 $domain"
  fi
else
    echo "You may need to add these lines to your Windows hosts file to acces the site :"
    echo "127.0.0.1 $domain"
    echo "::1 $domain"
fi



