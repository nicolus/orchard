#!/usr/bin/env bash

declare me=$1
declare current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && /bin/pwd)"

echo "installing for user $me"

export DEBIAN_FRONTEND=noninteractive

# Update Package List
apt-get update

# Remove desktop components
apt-get autoremove -y x11-utils x11-common

# Update System Packages
apt-get upgrade -y

# Install Some PPAs
apt-get install -y curl wget apt-transport-https software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -

# Update Package Lists again to get packages from ondrej
apt-get update

# Install Some Basic Packages
apt-get install -y build-essential dos2unix gcc git libmcrypt4 libpcre3-dev libpng-dev chrony unzip make \
supervisor unattended-upgrades whois vim libnotify-bin pv cifs-utils mcrypt bash-completion imagemagick \
apache2 libapache2-mod-fcgid

#Enable apache modules
a2enmod proxy proxy_http ssl
# Listen on ipv4 instead of ipv6 :
sed -i "s/Listen 80/Listen 0.0.0.0:80/" /etc/apache2/ports.conf
sed -i "s/Listen 443/Listen 0.0.0.0:443/" /etc/apache2/ports.conf


# Set My Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

declare -a php_versions=("7.2" "7.3" "7.4" "8.0")
for version in "${php_versions[@]}"
do
	apt-get install -y --allow-change-held-packages \
	php${version} php${version}-bcmath php${version}-bz2 php${version}-cgi php${version}-cli php${version}-common php${version}-curl php${version}-dev \
	php${version}-fpm php${version}-gd php${version}-gmp php${version}-imap php${version}-interbase php${version}-intl php${version}-json php${version}-xdebug \
	php${version}-mbstring php${version}-mysql php${version}-opcache php${version}-readline \
	php${version}-soap php${version}-sqlite3 php${version}-tidy php${version}-xml php${version}-xmlrpc php${version}-xsl php${version}-zip \
	php${version}-imagick php${version}-memcached php${version}-redis

  # We're installing all php versions in order, so we'll be left with the latest one active :
	update-alternatives --set php /usr/bin/php${version}
	update-alternatives --set php-config /usr/bin/php-config${version}
	update-alternatives --set phpize /usr/bin/phpize${version}
	
	# Set Some PHP CLI Settings
	sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${version}/cli/php.ini
	sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${version}/cli/php.ini
	sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${version}/cli/php.ini
	sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${version}/cli/php.ini

	# Setup Some PHP-FPM Options
	echo "xdebug.mode = debug" >> /etc/php/${version}/mods-available/xdebug.ini
	echo "xdebug.remote_port = 9003" >> /etc/php/${version}/mods-available/xdebug.ini

	sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${version}/fpm/php.ini
	sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${version}/fpm/php.ini
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/${version}/fpm/php.ini
	sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${version}/fpm/php.ini
	sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/${version}/fpm/php.ini
	sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/${version}/fpm/php.ini
	sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/${version}/fpm/php.ini

	printf "[openssl]\n" | tee -a /etc/php/${version}/fpm/php.ini
	printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/${version}/fpm/php.ini

	printf "[curl]\n" | tee -a /etc/php/${version}/fpm/php.ini
	printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/${version}/fpm/php.ini

done

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Disable XDebug On The CLI
phpdismod -s cli xdebug

# Install Node
apt-get install -y nodejs

# Install SQLite
apt-get install -y sqlite3 libsqlite3-dev

# Install MySQL
apt-get install -y mysql-server

# Configure MySQL Password Lifetime
echo "default_password_lifetime = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf

# Configure MySQL Remote Access
sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
service mysql restart

mysql --user="root" --password="secret" -e "CREATE USER 'dbuser'@'%' IDENTIFIED BY 'secret';"
mysql --user="root" --password="secret" -e "GRANT ALL ON *.* TO 'dbuser'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
mysql --user="root" --password="secret" -e "FLUSH PRIVILEGES;"
mysql --user="root" --password="secret" -e "CREATE DATABASE db character set UTF8mb4 collate utf8mb4_bin;"

tee "/home/$me/.my.cnf" <<EOL
[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_bin
EOL

# Add Timezone Support To MySQL
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root --password=secret mysql
service mysql restart

# Install Redis & Memcached
apt-get install -y redis-server memcached
#service redis-server start

# Install & Configure MailHog
wget --quiet -O /usr/local/bin/mailhog https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_amd64
chmod +x /usr/local/bin/mailhog


# Configure Supervisor for mailhog
cp "$current_dir/../resources/mailhog.conf" "/etc/supervisor/conf.d/"
#service supervisor start

# Install ngrok
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip -d /usr/local/bin
rm -rf ngrok-stable-linux-amd64.zip

# Clean Up
apt -y autoremove
apt -y clean
chown -R "$me:$me" "/home/$me"
chown -R "$me:$me" /usr/local/bin

# Add Composer Global Bin To Path
printf "\nPATH=\"$(sudo su - $me -c 'composer config -g home 2>/dev/null')/vendor/bin:\$PATH\"\n" | tee -a "/home/$me/.profile"

#Copy files and scripts to ~/
cp "$current_dir/../resources/aliases.sh" "/home/$me/.bash_aliases"
cp -r "$current_dir/../scripts/" "/home/$me/"

mv "/home/$me/scripts/start.sh" /usr/bin/start
chmod /usr/bin/start 755

#Allow using sudo without entering a password
echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

apt-get -y autoremove;
apt-get -y clean;

## Install the mailhog site
bash /home/"$me"/scripts/create-certificate.sh mailhog.test
cp "$current_dir/../resources/mailhog.test.conf" "/etc/apache2/sites-available/"
a2ensite mailhog.test
bash /home/"$me"/scripts/update-hosts.sh mailhog.test

## Install a welcome page :
mkdir /var/www/orchard
cp "$current_dir/../resources/welcome.php" "/var/www/orchard/index.php"
bash /home/"$me"/scripts/create-certificate.sh orchard.test
bash /home/"$me"/scripts/update-hosts.sh orchard.test
bash /home/"$me"/scripts/apache.sh orchard.test /var/www/orchard/ 7.4

source /home/"$me"/.bashrc

start

/mnt/c/Windows/explorer.exe http://orchard.test

exit
