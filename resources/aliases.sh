alias ..="cd .."
alias ...="cd ../.."

alias h='cd ~'
alias c='clear'
alias art='artisan'
alias tkr='php artisan tinker'

alias phpspec='vendor/bin/phpspec'
alias phpunit='vendor/bin/phpunit'

alias xoff='sudo phpdismod xdebug && php-restart'
alias xon='sudo phpenmod xdebug && php-restart'

function artisan() {
    php artisan "$@"
}

function hostip() {
	tail -1 /etc/resolv.conf | cut -d' ' -f2
}

function php-restart() {
  for dir in "/etc/php/"* ; do
      version=$(basename "$dir")
      sudo service php"$version"-fpm restart
  done
}

function php80() {
    sudo update-alternatives --set php /usr/bin/php8.0
    sudo update-alternatives --set php-config /usr/bin/php-config8.0
    sudo update-alternatives --set phpize /usr/bin/phpize8.0
}

function php81() {
    sudo update-alternatives --set php /usr/bin/php8.1
    sudo update-alternatives --set php-config /usr/bin/php-config8.1
    sudo update-alternatives --set phpize /usr/bin/phpize8.1
}

function php82() {
    sudo update-alternatives --set php /usr/bin/php8.2
    sudo update-alternatives --set php-config /usr/bin/php-config8.2
    sudo update-alternatives --set phpize /usr/bin/phpize8.2
}

function php83() {
    sudo update-alternatives --set php /usr/bin/php8.3
    sudo update-alternatives --set php-config /usr/bin/php-config8.3
    sudo update-alternatives --set phpize /usr/bin/phpize8.3
}

function serve() {
    if [[ "$1" && "$2" ]]
    then
        me=$(whoami)
        sudo bash /home/"${me}"/scripts/create-certificate.sh "$1"
        sudo dos2unix /home/"${me}"/scripts/apache.sh
        sudo bash /home/"${me}"/scripts/apache.sh "$1" "$2" "${3:-8.1}"
        sudo bash /home/"${me}"/scripts/update-hosts.sh "$1"
    else
        echo "Error: missing required parameters."
        echo "Usage: "
        echo "  serve domain path [phpversion]"
    fi
}

function share() {
    if [[ "$1" ]]
    then
        ngrok http "${@:2}" -host-header="$1" 80
    else
        echo "Error: missing required parameters."
        echo "Usage: "
        echo "  share domain"
        echo "Invocation with extra params passed directly to ngrok"
        echo "  share domain -region=eu -subdomain=test1234"
    fi
}

function xphp() {

    if (php -m | grep -q xdebug)
    then
        XDEBUG_ENABLED=true
    else
        XDEBUG_ENABLED=false
    fi

    if ! $XDEBUG_ENABLED; then xon; fi

    HOST_IP=$(hostip)

    php \
      -dxdebug.client_host=${HOST_IP} \
      -dxdebug.start_with_request=1 \
      "$@"

    if ! $XDEBUG_ENABLED; then xoff; fi
}

function xart() {
	xphp artisan "$@"
}
