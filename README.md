Webmin install script & plugins
===============================

Install Webmin on several Linux distributions with one script

* Installs all dependencies using apt or yum

Tested on:
* CentOS 5.8/6.4
* Debian 6.0/7.0
* Fedora 17
* Ubuntu 10.04/12.04/12.10/13.04

Default temp dir is ````/tmp/webmin````, this can be changed in install script.

By default, the installer logs into ````$TMP/install.log```` and ````$TMP/error.log````. Check these for further info about the installation process.

## Dependencies
* Package manager (apt or yum)
* HTTP Client (curl, wget or fetch)

Dependencies will be installed during the progress, but installing them on your own is advised.

## Installation

### Online installation

Clone this repository and run ````install.sh````

OR

Just download ````install.sh```` and run it.

### Install from package

Download the appropriate package and install it with your package manager depending on your distribution:

##### Debian

[Webmin DEB package](http://prdownloads.sourceforge.net/webadmin/webmin_1.650_all.deb)

````dpkg --install webmin_1.650_all.deb````

If Debian complains about missing dependencies, install them with the command:

````apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python````

##### RHEL

[Webmin RPM package](http://prdownloads.sourceforge.net/webadmin/webmin-1.650-1.noarch.rpm)

````rpm -U webmin-1.650-1.noarch.rpm````

This way you can install Supervisor on any machine even without internet connection. Make sure that every dependency is installed.

### Manual Installation
[Follow these instructions](http://www.webmin.com/tgz.html)



For further info check [Official website](http://www.webmin.com/)