<p align="center"><img src="/resources/orchard.png" title="Orchard" alt="Orchard logo"></p>

# Orchard

> A LAMP development Stack for WSL2


## What is this ?

Orchard is a provisioning script that makes it really fast and easy to install a full LAMP stack on windows 10/11 with Ubuntu 22.04 on WSL2. It will install and configure the following :

* Apache 2
* PHP 8.0, 8.1, 8.2 and 8.3
* MySQL 8.0
* Redis
* Memcache
* ngrok
* Mailpit
* SSL certificates
* Shared SSH keys between windows and WSL

It borrows a lot from laravel/settler and laravel/homestead.

---

## Requirements

* Windows 10 version 2004 or later
* [WSL2](https://docs.microsoft.com/windows/wsl/about)
* A fresh install of [Ubuntu 22.04 for WSL](https://apps.microsoft.com/detail/9PN20MSR04DW?hl=fr-fr&gl=FR)
* I also recommend you install [Windows Terminal](https://apps.microsoft.com/detail/9N0DX20HK701) because it's really good ;-)

## Installation

Install Ubuntu 22.04 with a username (not just `root`) and start it by typing `ubuntu` in the command line

Add the following lines to your hosts file (C:\Windows\System32\drivers\etc\hosts) so that you'll be able to access the default orchard websites, you can also add any site you know you'll want to create in orchard. :
```
127.0.0.1 orchard.test
::1 orchard.test

127.0.0.1 mailhog.test
::1 mailpit.test
```

Download this repository somewhere and double click the `install.bat` file in the root directory. 

It will then prompt you to enter your password to gain sudo access and proceed to install everything you need.

If you don't see anything going wrong in the logs, it means Orchard is now installed, congratulations ! (it should even have opened a test page in your browser).

You can now install the Root certificate located in `\\wsl$\Ubuntu\etc\apache2\ssl\ca.orchard.YOUR-MACHINE-NAME.crt` in Chrome and Firefox so that your sites will in https without any warning.


## Usage

Since Orchard borrows a lot from Laravel Homestead, most of what you can do is very similar.

Serve a website from a directory (don't forget to make the domain point to 127.0.0.1 in your hosts file):
```shell script
$ serve /var/www/mysite mysite.test 
```

It will use php 8.3 by default, but you can specify an older version :
```shell script
$ serve /var/www/mysite mysite.test 8.1
```

Change the current php version used in CLI
```shell script
$ php81
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