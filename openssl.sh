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
