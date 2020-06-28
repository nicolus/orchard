alias ..="cd .."
alias ...="cd ../.."

alias h='cd ~'
alias c='clear'
alias art=artisan

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

function serve() {
    if [[ "$1" && "$2" ]]
    then
        me=$(whoami)
        sudo bash /home/"${me}"/scripts/create-certificate.sh "$1"
        sudo dos2unix /home/"${me}"/scripts/apache.sh
        sudo bash /home/"${me}"/scripts/apache.sh "$1" "$2" "${3:-7.4}"
        sudo bash /home/"${me}"/scripts/update-hosts.sh "$1"
    else
        echo "Error: missing required parameters."
        echo "Usage: "
        echo "  serve domain path"
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
    (php -m | grep -q xdebug)
    if [[ $? -eq 0 ]]
    then
        XDEBUG_ENABLED=true
    else
        XDEBUG_ENABLED=false
    fi

    if ! $XDEBUG_ENABLED; then xon; fi

    HOST_IP=hostip

    php \
        -dxdebug.remote_host=${HOST_IP} \
        -dxdebug.remote_autostart=1 \
        "$@"

    if ! $XDEBUG_ENABLED; then xoff; fi
}

function xart() {
	xphp artisan "$@"
}
