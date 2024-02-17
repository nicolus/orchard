#!/usr/bin/env bash

## You can add older/newer PHP versions here,
## eg : declare -a php_versions=("8.1" "8.2" "8.3")
declare -a php_versions=("8.0" "8.1" "8.2" "8.3")

## You can add or remove databases here :
## eg : declare -a databases=("laravel" "test_database")
declare -a databases=("laravel")

## NodeJS version you want to install
NODE_MAJOR="20"

## Variables we will need to provision : current user, current dir and host ip (IP of the host windows seen from WSL)
me=$1
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && /bin/pwd)"
host_ip="$(tail -1 /etc/resolv.conf | cut -d' ' -f2)"

echo "installing for user $me"

export DEBIAN_FRONTEND=noninteractive

# Update Package List
apt-get update

# Remove Snapd to save some space and resources
snap remove ubuntu-desktop-installer
snap remove gtk-common-themes
snap remove core22
snap remove bare
snap remove snapd
apt-get purge -y snapd

# Remove Apparmor to avoid potential headaches in local dev environment (never do that in production)
apt-get purge -y apparmor

# Update System Packages
apt-get upgrade -y

# Add Odrej's PHP PPA
add-apt-repository ppa:ondrej/php -y

# Add NodeJS PPA
apt-get install -y ca-certificates curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" |  tee /etc/apt/sources.list.d/nodesource.list

# Update Package Lists again to get packages from ondrej and node repos
apt-get update -y

# Install Some Basic Packages
apt-get install -y dos2unix git libmcrypt4 libpcre3-dev libpng-dev unzip supervisor whois

# Set My Timezone to UTC
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Share .ssh directory between windows and linux so we can use the same keys for git etc.
echo "$SSH_PATH /home/$me/.ssh drvfs rw,noatime,uid=1000,gid=1000,case=off,umask=0077,fmask=0177 0 0" | tee /etc/fstab


####################################
#             APACHE 2             #
####################################
# Install apache 2
apt-get install -y apache2 libapache2-mod-fcgid

# Add Mutex to config to prevent auto restart issues
echo 'Mutex posixsem' | sudo tee -a /etc/apache2/apache2.conf

# Set the apache user as the current user for easier right management (don't do that in production !)
sed -i "s/APACHE_RUN_USER=.*/APACHE_RUN_USER=$me/" "/etc/apache2/envvars"

#Enable apache modules
a2enmod proxy proxy_fcgi proxy_http ssl rewrite headers actions alias


####################################
#                PHP               #
####################################

for version in "${php_versions[@]}"
do
	apt-get install -y \
	php${version} php${version}-bcmath php${version}-bz2 php${version}-cgi php${version}-cli php${version}-common php${version}-curl  \
	php${version}-fpm php${version}-gd php${version}-gmp php${version}-imap php${version}-intl php${version}-xdebug \
	php${version}-mbstring php${version}-mysql php${version}-opcache php${version}-readline \
	php${version}-sqlite3 php${version}-xml php${version}-xsl php${version}-zip php${version}-redis

	# Set Some PHP CLI Settings by using search/replace with sed
	sed -i "s/error_reporting = .*/error_reporting = E_ALL/" "/etc/php/$version/cli/php.ini"
	sed -i "s/display_errors = .*/display_errors = On/" "/etc/php/$version/cli/php.ini"
	sed -i "s/memory_limit = .*/memory_limit = 512M/" "/etc/php/$version/cli/php.ini"
	sed -i "s/;date.timezone.*/date.timezone = UTC/" "/etc/php/$version/cli/php.ini"

	# Set php-fpm user as current user so CLI and web scripts will have the same user :
  sed -i "s/user = .*/user =  $me/" "/etc/php/$version/fpm/pool.d/www.conf"
  sed -i "s/listen\.owner.*/listen.owner = $me/" "/etc/php/$version/fpm/pool.d/www.conf"
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" "/etc/php/$version/fpm/pool.d/www.conf"


  echo "xdebug.mode = debug" >> "/etc/php/$version/mods-available/xdebug.ini"
  echo "xdebug.client_host = $host_ip" >> "/etc/php/$version/mods-available/xdebug.ini"
  echo "xdebug.client_port = 9003" >> "/etc/php/$version/mods-available/xdebug.ini"
	echo "xdebug.max_nesting_level = 512" >> "/etc/php/$version/mods-available/xdebug.ini"

	sed -i "s/error_reporting = .*/error_reporting = E_ALL/" "/etc/php/$version/fpm/php.ini"
	sed -i "s/display_errors = .*/display_errors = On/" "/etc/php/$version/fpm/php.ini"
	sed -i "s/memory_limit = .*/memory_limit = 512M/" "/etc/php/$version/fpm/php.ini"
	sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" "/etc/php/$version/fpm/php.ini"
	sed -i "s/post_max_size = .*/post_max_size = 100M/" "/etc/php/$version/fpm/php.ini"
	sed -i "s/;date.timezone.*/date.timezone = UTC/" "/etc/php/$version/fpm/php.ini"

  # Make php use the system ca certificates so it won't complain about untrusted certificates :
	echo "[openssl]" >> "/etc/php/$version/fpm/php.ini"
	echo "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt" >> "/etc/php/$version/fpm/php.ini"

	echo "[openssl]" >> "/etc/php/$version/cli/php.ini"
  echo "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt" >> "/etc/php/$version/cli/php.ini"

	echo "[curl]" >> "/etc/php/$version/fpm/php.ini"
	echo "curl.cainfo = /etc/ssl/certs/ca-certificates.crt" >> "/etc/php/$version/fpm/php.ini"

  echo "[curl]" >> "/etc/php/$version/cli/php.ini"
  echo "curl.cainfo = /etc/ssl/certs/ca-certificates.crt" >> "/etc/php/$version/fpm/php.ini"

	# set php to aliases of phpX.Y
	# We're installing all php versions in order, so we'll be left with the latest one active :
	update-alternatives --set php "/usr/bin/php$version"
done

# Disable XDebug On The CLI (can still be used with 'xphp')
phpdismod -s cli xdebug

# Set the servername in PHPIDECONFIG environment variable to enable path mapping in the IDE :
echo "export PHP_IDE_CONFIG=\"serverName=$(hostname)\"" >> "/home/$me/.profile"

# Install Composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Add Composer Global Bin To Path
printf "\nPATH=\"$(sudo su - $me -c 'composer config -g home 2>/dev/null')/vendor/bin:\$PATH\"\n" | tee -a "/home/$me/.profile"


####################################
#                MYSQL             #
####################################
# Install MySQL
apt-get install -y --no-install-recommends mysql-server

service mysql stop

# Configure MySQL Password Lifetime to never expire
echo "default_password_lifetime = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf

# Configure MySQL Remote Access to allow access from anywhere
sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

echo "
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci

# Use legacy authentication plugin for better compatibility :
default-authentication-plugin=mysql_native_password

# Disable performance schema and binary logs. We usually don't need them for development
# And disabling them improves performance and memory consumption
performance_schema=OFF
disable_log_bin
" >> /etc/mysql/mysql.conf.d/mysqld.cnf

# Give a home directory to "mysql" user to get rid of an annoying warning that "/nonexistent" doesn't exist
usermod -d /var/lib/mysql/ mysql

service mysql start

# And allow root to connect from anywhere
mysql --user="root" -e "UPDATE mysql.user SET host='%' WHERE user='root';"
mysql --user="root" -e "FLUSH PRIVILEGES"
mysql --user="root" -e "ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY ''"

# Create the databases :
for db in "${databases[@]}"; do
  mysql --user="root" -e "CREATE DATABASE $db character set UTF8mb4 collate utf8mb4_unicode_ci;"
done


# Add Timezone Support To MySQL
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql --user=root




####################################
#                MISC              #
####################################

# Install Node
apt-get install -y nodejs

# Install SQLite
apt-get install -y sqlite3 libsqlite3-dev

# Install memcached
#apt-get install -y memcached

# Install Redis
apt-get install -y redis-server
service redis-server start

# Install & Configure Mailpit
sudo bash < <(curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh)

# Configure Supervisor for mailpit
cp "$current_dir/../resources/mailpit.conf" "/etc/supervisor/conf.d/"

#start supervisor :
service supervisor start

# Install ngrok
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip -d /usr/local/bin
rm -rf ngrok-stable-linux-amd64.zip

# Clean Up
apt-get -y autoremove
apt-get -y clean
chown -R "$me:$me" "/home/$me"
chown -R "$me:$me" /usr/local/bin

# Copy files and scripts to ~/
cp "$current_dir/../resources/aliases.sh" "/home/$me/.bash_aliases"
cp -r "$current_dir/../scripts/" "/home/$me/"

# Move the start.sh script and change permissions to make it executable
mv "/home/$me/scripts/start.sh" /usr/bin/start
chmod 755 /usr/bin/start

# Allow using sudo without entering a password
echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Cleanup !
apt-get -y autoremove;
apt-get -y clean;

# Install the mailpit site
bash /home/"$me"/scripts/create-certificate.sh mailpit.test
cp "$current_dir/../resources/mailpit.test.conf" "/etc/apache2/sites-available/"
a2ensite mailpit.test
bash /home/"$me"/scripts/update-hosts.sh mailpit.test

# Install a welcome page :
mkdir /var/www/orchard
cp "$current_dir/../resources/welcome.php" "/var/www/orchard/index.php"
bash /home/"$me"/scripts/create-certificate.sh orchard.test
bash /home/"$me"/scripts/update-hosts.sh orchard.test
bash /home/"$me"/scripts/apache.sh orchard.test /var/www/orchard/ 8.3

# Make user part of www-data group and owner of /var/www so that we can set permissions to 775
# on directories that need to be writable by apache (like ./storage or ./bootstrap/cache)
usermod -g www-data "$me"
chown -R "$me:www-data" /var/www

/mnt/c/Windows/explorer.exe http://orchard.test

exit
