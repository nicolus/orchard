alias ..="cd .."
alias ...="cd ../.."

alias h='cd ~'
alias c='clear'
alias art=artisan
alias tkr='php artisan tinker'

alias phpspec='vendor/bin/phpspec'
alias phpunit='vendor/bin/phpunit'

alias xoff='sudo phpdismod xdebug'
alias xon='sudo phpenmod xdebug'


function artisan() {
    php artisan "$@"
}

function hostip() {
	tail -1 /etc/resolv.conf | cut -d' ' -f2
}


function php70() {
    sudo update-alternatives --set php /usr/bin/php7.0
    sudo update-alternatives --set php-config /usr/bin/php-config7.0
    sudo update-alternatives --set phpize /usr/bin/phpize7.0
}

function php71() {
    sudo update-alternatives --set php /usr/bin/php7.1
    sudo update-alternatives --set php-config /usr/bin/php-config7.1
    sudo update-alternatives --set phpize /usr/bin/phpize7.1
}

function php72() {
    sudo update-alternatives --set php /usr/bin/php7.2
    sudo update-alternatives --set php-config /usr/bin/php-config7.2
    sudo update-alternatives --set phpize /usr/bin/phpize7.2
}

function php73() {
    sudo update-alternatives --set php /usr/bin/php7.3
    sudo update-alternatives --set php-config /usr/bin/php-config7.3
    sudo update-alternatives --set phpize /usr/bin/phpize7.3
}

function php74() {
    sudo update-alternatives --set php /usr/bin/php7.4
    sudo update-alternatives --set php-config /usr/bin/php-config7.4
    sudo update-alternatives --set phpize /usr/bin/phpize7.4
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

    if (php -v | grep -q "PHP 7.[01]")
    then
      # php 7.0 or 7.1 => Xdebug 2
      php \
        -dxdebug.remote_host=${HOST_IP} \
        -dxdebug.remote_autostart=1 \
        "$@"
    else
      # php 7.2 or higher => Xdebug 3
      php \
        -dxdebug.client_host=${HOST_IP} \
        -dxdebug.start_with_request=1 \
        "$@"
    fi

    if ! $XDEBUG_ENABLED; then xoff; fi
}

function xart() {
	xphp artisan "$@"
}
