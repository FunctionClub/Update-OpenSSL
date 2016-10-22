#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin


#Check OS
if [ -n "$(grep 'Aliyun Linux release' /etc/issue)" -o -e /etc/redhat-release ];then
    OS=CentOS
    [ -n "$(grep ' 7\.' /etc/redhat-release)" ] && CentOS_RHEL_version=7
    [ -n "$(grep ' 6\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release6 15' /etc/issue)" ] && CentOS_RHEL_version=6
    [ -n "$(grep ' 5\.' /etc/redhat-release)" -o -n "$(grep 'Aliyun Linux release5' /etc/issue)" ] && CentOS_RHEL_version=5
elif [ -n "$(grep 'Amazon Linux AMI release' /etc/issue)" -o -e /etc/system-release ];then
    OS=CentOS
    CentOS_RHEL_version=6
elif [ -n "$(grep bian /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Debian' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Deepin /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Deepin' ];then
    OS=Debian
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Debian_version=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep Ubuntu /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'Ubuntu' -o -n "$(grep 'Linux Mint' /etc/issue)" ];then
    OS=Ubuntu
    [ ! -e "$(which lsb_release)" ] && { apt-get -y update; apt-get -y install lsb-release; clear; }
    Ubuntu_version=$(lsb_release -sr | awk -F. '{print $1}')
    [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_version=16
else
    echo "${CFAILURE}Does not support this OS, Please contact the author! ${CEND}"
    kill -9 $$
fi

if [ ${OS}=Ubuntu ];then
	apt-get update -y && apt-get upgrade -y
	cd /root
	echo "Install basic Toolkit"
	apt-get install libpcre3 libpcre3-dev unzip git zlib1g-dev build-essential -y
	echo "Install Zlib"
	cd /root
	wget http://zlib.net/zlib-1.2.8.tar.gz
	tar -zxf zlib-1.2.8.tar.gz
	cd zlib*
	./configure
	make test
	make install
	make clean
	./configure --shared
	make test
	make install
	cp zutil.h /usr/local/include
	cp zutil.c /usr/local/include
	echo "Install OpenSSL 1.0.2"
	cd /root
	wget -c https://github.com/openssl/openssl/archive/OpenSSL_1_0_2-stable.zip
	git clone https://github.com/cloudflare/sslconfig
	apt-get purge openssl -y
	rm -rf /etc/ssl
	unzip OpenSSL_1_0_2-stable.zip && mv openssl-OpenSSL_1_0_2-stable openssl
	cd openssl && patch -p1 < ../sslconfig/patches/openssl__chacha20_poly1305_cf.patch
	./config --prefix=/usr shared zlib-dynamic
	make depend
	make && make install
	echo "Clean Useless Things"
	cd /root
	rm -rf openssl  zlib-1.2.8  zlib-1.2.8.tar.gz  OpenSSL_1_0_2-stable.zip  sslconfig
fi





#Install Progress In CentOS
if [ ${OS}=CentOS ];then
	mkdir Openssl
	cd Openssl
	echo "Install basic Toolkit"
	yum -y install pcre-devel zlib unzip git patch
	echo "Update Gcc"
	yum -y remove gcc gcc-c++
	wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
	yum -y install devtoolset-2-gcc devtoolset-2-binutils devtoolset-2-gcc-c++
	ln -s /opt/rh/devtoolset-2/root/usr/bin/gcc /usr/bin/gcc
	ln -s /opt/rh/devtoolset-2/root/usr/bin/gcc /usr/bin/cc
	echo "Install Zlib"
	wget http://zlib.net/zlib-1.2.8.tar.gz
	tar -zxf zlib-1.2.8.tar.gz
	cd zlib*
	./configure
	make test
	make install
	make clean
	./configure --shared
	make test
	make install
	cp zutil.h /usr/local/include
	cp zutil.c /usr/local/include
	cd ../
	echo "Download openSSL"
	wget https://www.openssl.org/source/openssl-1.0.2-latest.tar.gz
	tar -zxf openssl-1.0.2-latest.tar.gz
	echo "Move to openSSL"
	cd openssl-1.0.2*
	echo "Download and install openSSL Addons about Chacha 20"
	git clone https://github.com/cloudflare/sslconfig
	cd sslconfig/patches
	mv * ../../
	cd ../../
	patch -p1 < openssl__chacha20_poly1305_cf.patch
	echo "Install openSSL"
	./config --prefix=/usr shared zlib-dynamic
	make depend
	make && make install
	echo "Clean useless things"
	rm -rf Openssl
	clear
	echo "Update GCC && OpenSSL Successfully!"
fi


