#!/bin/bash

# Script to install Webmin
# Author: Márk Sági-Kazár (sagikazarmark@gmail.com)
# This script installs Webmin on several Linux distributions.
#
# Version: 1.650

# Variable definitions
DIR=$(cd `dirname $0` && pwd)
NAME="Webmin"
SLUG="webmin"
VER="1.650"
DEPENDENCIES=("python")
TMP="/tmp/$NAME"
INSTALL_LOG="$TMP/install.log"
ERROR_LOG="$TMP/error.log"

# Cleaning up
rm -rf $TMP
mkdir -p $TMP
cd $TMP
chmod 777 $TMP


# Basic function definitions

## Echo colored text
e()
{
	local color="\033[${2:-34}m"
	local log="${3:-$INSTALL_LOG}"
	echo -e "$color$1\033[0m"
	log "$1" "$log"
}

## Exit error
ee()
{
	local exit_code="${2:-1}"
	local color="${3:-31}"

	clear
	e "$1" "$color" "$ERROR_LOG"
	exit $exit_code
}

## Log messages
log()
{
	local log="${2:-$INSTALL_LOG}"
	echo "$1" >> "$log"
}

## Add dependency
dep()
{
	if [ ! -z "$1" ]; then
		DEPENDENCIES+=("$1")
	fi
}


# Checking root access
if [ $EUID -ne 0 ]; then
	ee "This script has to be ran as root!"
fi

# CTRL_C trap
ctrl_c()
{
	clear
	echo
	echo "Installation aborted by user!"
	cleanup
}
trap ctrl_c INT

# Basic checks

## Check for wget or curl or fetch
e "Checking for HTTP client..."
if [ `which curl 2> /dev/null` ]; then
	download="$(which curl) -s -O"
elif [ `which wget 2> /dev/null` ]; then
	download="$(which wget) --no-certificate"
elif [ `which fetch 2> /dev/null` ]; then
	download="$(which fetch)"
else
	dep "wget"
	download="$(which wget) --no-certificate"
	e "No HTTP client found, wget added to dependencies" 31
fi

## Check for package manager (apt or yum)
e "Checking for package manager..."
if [ `which apt-get 2> /dev/null` ]; then
	install[0]="apt"
	install[1]="$(which apt-get) -y --force-yes install"
elif [ `which yum 2> /dev/null` ]; then
	install[0]="yum"
	install[1]="$(which yum) -y install"
else
	ee "No package manager found."
fi

## Check for package manager (dpkg or rpm)
if [ `which dpkg 2> /dev/null` ]; then
	install[2]="dpkg"
	install[3]="$(which dpkg)"
elif [ `which rpm 2> /dev/null` ]; then
	install[2]="rpm"
	install[3]="$(which rpm)"
else
	ee "No package manager found."
fi


# Function definitions

## Install required packages
install()
{
	if [ -z "$1" ]; then
		e "Package not given" 31
		return 1
	else
		e "Installing package: $1"
		${install[1]} "$1" >> $INSTALL_LOG 2>> $ERROR_LOG || ee "Error during install $1"
		e "Package $1 successfully installed"
	fi

	return 0
}

## Check installed package
check()
{
	if [ -z "$1" ]; then
		e "Package not given" 31
		return 2
	else
		case ${install[2]} in
			dpkg )
				${install[3]} -s "$1" &> /dev/null
				;;
			rpm )
				${install[3]} -qa | grep "$1"  &> /dev/null
				;;
		esac
		return $?
	fi
}

## Download required file
download()
{
	if [ -z "$1" ]; then
		e "No download given" 31
		return 1
	else
		$download "$1" >> $INSTALL_LOG 2>> $ERROR_LOG || ee "Error during download $2"
	fi

	return 0
}

## Cleanup files
cleanup()
{
	cd $TMP 2> /dev/null || return 1
	find * -not -name '*.log' | xargs rm -rf
}

# Checking dependencies
for dep in ${DEPENDENCIES[@]}; do
	check "$dep"
	[ $? -eq 0 ] || install "$dep"
done


download http://www.webmin.com/jcameron-key.asc "Webmin GPG Key"

if [ `which apt-get 2> /dev/null` ]; then
	echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list.d/webmin.list
	echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list.d/webmin.list

	apt-key add jcameron-key.asc >> $INSTALL_LOG 2>> $ERROR_LOG
	apt-get update &> /dev/null
elif [ `which yum 2> /dev/null` ]; then
echo "[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1" >> /etc/yum.repos.d/webmin.repo
	rpm --import jcameron-key.asc >> $INSTALL_LOG 2>> $ERROR_LOG
else
	ee "Your distribution is not supported!"
fi

install "webmin"

e "Cleaning up"
cleanup

if [ -s $ERROR_LOG ]; then
	e "Error log is not empty. Please check $ERROR_LOG for further details." 31
fi

e "Installation done."
