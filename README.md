<p align="center"><img src="/resources/orchard.png" title="Orchard" alt="Orchard logo"></p>

# Orchard

> A LAMP development Stack for WSL2


## What is this ?

Orchard is a provisioning script that makes it really fast and easy to install a full LAMP stack on windows 10 with Ubuntu 20.04 on WSL2. It will install and configure the following :

* Apache 2
* PHP 7.0, 7.1, 7.2, 7.3, 7.4 and 8.0
* MySQL 8.0
* Redis
* Memcache
* ngrok
* Mailhog
* SSL certificates

It borrows a lot from laravel/settler and laravel/homestead.

---

## Requirements

* Windows 10 version 2004 or later
* [WSL2](https://docs.microsoft.com/windows/wsl/about)
* A fresh install of [Ubuntu 20.04 for WSL](https://www.microsoft.com/en-us/p/ubuntu-2004-lts/9n6svws3rx71?activetab=pivot:overviewtab)
* I also recommend you install [Windows Terminal](https://github.com/microsoft/terminal) because it's really good ;-)

## Installation

Download this repo somewhere (let's assume `C:\orchard\ `)

Install Ubuntu 20.04 with a username (not just `root`) and start it by typing `ubuntu` in the command line

Add the following lines to your hosts file (C:\Windows\System32\drivers\etc\hosts) so that you'll be able to access the default orchard websites, you can also add any site you know you'll want to create in orchard. :
```
127.0.0.1 orchard.test
::1 orchard.test

127.0.0.1 mailhog.test
::1 mailhog.test
```

Navigate to where you downloaded the repo : 
```shell script
$ cd /mnt/c/orchard
```

Launch the install script :
```shell script
$ ./install.sh
```

It will then prompt you to enter your password to gain sudo access and proceed to install everything you need.

If you don't see anything going wrong in the logs, it means Orchard is now installed, congratulations ! (it should even have opened a test page in your browser).

Reload the bash_aliases (or you can log off and on again from wsl) :
```
$ source ~/.bash_aliases
```

You can now install the Root certificate located in `\\wsl$\Ubuntu\etc\apache2\ssl\ca.orchard.YOUR-MACHINE-NAME.crt` in Chrome and Firefox so that your sites will work without warning in https.


## Usage

Since Orchard borrows a lot from Laravel Homestead, most of what you can do is very similar.

Serve a website from a directory (don't forget to make the domain point to 127.0.0.1 in your hosts file):
```shell script
$ serve /var/www/mysite mysite.test 
```

It will use php 8.0 by default, but you can specify an older version :
```shell script
$ serve /var/www/mysite mysite.test 7.4
```

Change the current php version used in CLI
```shell script
$ php74
```

Launch a command line script with xdebug :
```shell script
$ xphp script.php
```
Get the IP of the host machine from WSL :
```shell script
$ hostip
```

Share a site with ngrok :
```shell script
$ share mysite.test
```

