#!/bin/bash
echo "Installing Begin~"
#export TARGET_DIR=${HOME}
export TARGET_DIR=`cd ../;pwd`

php_version=php-5.4.3
nginx_version=nginx-1.2.6
mysql_version=mysql-5.0.45
svn_version=subversion-1.6.17_with_dep
git_version=git-1.8.5

#dependency_version
mhash_version=mhash-0.9.7.1
libpng_version=libpng-1.5.8
libxml2_version=libxml2-2.6.26
zlib_version=zlib-1.2.3
libmcrypt_version=libmcrypt-2.5.8
openssl_version=openssl-1.0.1g
curl_version=curl-7.21.0

function install_dependency()
{
  echo "Check and install dependencies ..."
  cd $TARGET_DIR
  mkdir dependency

  cd $TARGET_DIR/install
  if [ ! -d $TARGET_DIR/dependency/mhash ]; then
     #wget -q $SOFTWARE_SOURCE/$mhash_version.tar.gz
     tar -xzvf $mhash_version.tar.gz -C $TARGET_DIR
     cd $TARGET_DIR/$mhash_version
     ./configure --prefix=$TARGET_DIR/dependency/mhash
     make -j4
     make install
     cd ..
  fi


  cd $TARGET_DIR/install
  if [ ! -d $TARGET_DIR/dependency/libpng ]; then
      #wget -q $SOFTWARE_SOURCE/$libpng_version.tar.gz
     tar -xzvf $libpng_version.tar.gz -C $TARGET_DIR
     cd $TARGET_DIR/$libpng_version
     ./configure --prefix=$TARGET_DIR/dependency/libpng
     make -j4
     make install
     cd ..
  fi
  
  cd $TARGET_DIR/install
  if [ ! -d $TARGET_DIR/dependency/libxml2 ] ;then
     #wget -q $SOFTWARE_SOURCE/$libxml2_version.tar.gz
     tar -xzvf $libxml2_version.tar.gz -C $TARGET_DIR
     cd $TARGET_DIR/$libxml2_version
     ./configure --prefix=$TARGET_DIR/dependency/libxml2
     make -j4
     make install
     cd ..
  fi

  cd $TARGET_DIR/install
  if [ ! -d $TARGET_DIR/dependency/zlib ] ;then
     #wget -q $SOFTWARE_SOURCE/$zlib_version.tar.gz
     tar -xzvf $zlib_version.tar.gz -C $TARGET_DIR
     cd $TARGET_DIR/$zlib_version
     ./configure --prefix=$TARGET_DIR/dependency/zlib --shared
     make -j4
     make install
     cd ..
  fi

  cd $TARGET_DIR/install
  if [ ! -d $TARGET_DIR/dependency/libmcrypt ] ;then
     #wget -q $SOFTWARE_SOURCE/$libmcrypt_version.tar.gz
     tar -xzvf $libmcrypt_version.tar.gz -C $TARGET_DIR
     cd $TARGET_DIR/$libmcrypt_version
     ./configure --prefix=$TARGET_DIR/dependency/libmcrypt
     make -j4
     make install
     cd ..
  fi

  cd $TARGET_DIR/install  
  if [ ! -d $TARGET_DIR/dependency/openssl ] ;then
     #wget -q $SOFTWARE_SOURCE/$openssl_version.tar.gz
     tar -xzvf $openssl_version.tar.gz -C $TARGET_DIR
     cd $TARGET_DIR/$openssl_version
     ./config shared --prefix=$TARGET_DIR/dependency/openssl
     make 
     make install
     cd ..
  fi

  cd $TARGET_DIR/install
  if [ ! -d $TARGET_DIR/dependency/libmemcached ] ;then
     #wget -q $SOFTWARE_SOURCE/libmemcached.tar.gz
     tar -xzvf libmemcached.tar.gz -C $TARGET_DIR/dependency
     cd ..
  fi

  cd $TARGET_DIR/install
  if [ ! -d $TARGET_DIR/dependency/curl ] ;then
     #wget -q $SOFTWARE_SOURCE/curl_version.tar.gz
     tar -xzvf $curl_version.tar.gz -C $TARGET_DIR
     cd $TARGET_DIR/$curl_version
     ./configure --prefix=$TARGET_DIR/dependency/curl --with-ssl=$TARGET_DIR/dependency/openssl --with-zlib=$TARGET_DIR/dependency/zlib
     make
     make install
     cd ..
  fi
}


function install_nginx()
{
 cd $TARGET_DIR/install
 if [ ! -d $TARGET_DIR/pcre ] ;then
   echo "Install pcre ..."
			      #wget
   tar -xjpf pcre-8.32.tar.bz2 -C $TARGET_DIR
   cd $TARGET_DIR/pcre-8.32
   make clean
   ./configure --prefix=$TARGET_DIR/pcre
   make
   make install
 fi
							      
 cd $TARGET_DIR/install
 if [ ! -d $TARGET_DIR/nginx ] ;then
   echo "Install Nginx ..."
									    #wget 
   tar -zxvf   $nginx_version.tar.gz -C $TARGET_DIR
   cd $TARGET_DIR/$nginx_version
   make clean
   ./configure  --prefix=$TARGET_DIR/nginx --with-http_stub_status_module --with-http_ssl_module --with-pcre=$TARGET_DIR/pcre-8.32 --with-http_realip_module
   #to add openssl
   make
   make install
   cd ..
 fi
}

function install_php()
{
  cd $TARGET_DIR/install
  if [ ! -d $TARGET_DIR/php ] ;then  
    echo "Install php ..." 
    #wget
    tar -zxvf $php_version.tar.gz -C $TARGET_DIR
    cd $TARGET_DIR/$php_version
    make clean
  #  ./configure --prefix=$TARGET_DIR/php --enable-fpm --enable-mbstring --disable-pdo  --disable-debug --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex  --enable-zip --with-pcre-regex  --without-iconv --with-mysql --with-gd  --enable-gd-native-ttf --without-sqlite  --with-gettext --enable-sockets --enable-bcmath --enable-xml   --enable-zip
    ./configure  --prefix=$TARGET_DIR/php --enable-fpm --enable-fastcgi --enable-bcmath --enable-gd-native-ttf --enable-mbstring --enable-shmop --enable-soap --enable-sockets --enable-exif --enable-ftp --enable-sysvsem --enable-pcntl --enable-wddx --enable-zip --enable-xml --enable-pdo --with-pcre-regex  --with-png-dir=$TARGET_DIR/dependency/libpng --with-gd --with-mcrypt=$TARGET_DIR/dependency/libmcrypt --with-pear --with-curlwrappers --with-openssl=$TARGET_DIR/dependency/openssl --with-zlib=$TARGET_DIR/dependency/zlib --with-curl=$TARGET_DIR/dependency/curl --with-iconv --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-jpeg-dir --with-freetype-dir --with-mhash=$TARGET_DIR/dependency/mhash
    make
    make install

    cd ..
    cp $TARGET_DIR/install/php.ini $TARGET_DIR/php/lib/
    rm $TARGET_DIR/php/etc/php-fpm.conf
    cp $TARGET_DIR/install/php-fpm.conf   $TARGET_DIR/php/etc/
    cp $TARGET_DIR/install/stop-fpm   $TARGET_DIR/php
   fi
}


function install_mysql()
{
  cd $TARGET_DIR/install
  if [ ! -d $TARGET_DIR/mysql ] ;then   
     echo "Install mysql ..." 
     #wget
     tar -zxvf $mysql_version.tar.gz -C $TARGET_DIR
     cd $TARGET_DIR/$mysql_version
     make clean
     ./configure --prefix=$TARGET_DIR/mysql --with-charset=utf8 --enable-local-infile --with-extra-charsets=all --enable-thread-safe-client --with-pic=yes --with-unix-socket-path=$TARGET_DIR/mysql/tmp/mysql.sock --with-tcp-port=8081 --with-mysqld-user=crm --with-plugins=all
     make
     make install
     cd $TARGET_DIR/mysql
     cp ./share/mysql/my-medium.cnf ./my.cnf
     cd ..
  fi
}

function install_phalcon()
{
  cd $TARGET_DIR/install
  if [ ! -d $TARGET_DIR/phalcon ] ;then   
     echo "Install phalcon ..." 
     #wget
     tar -zxvf cphalcon.tar.gz -C $TARGET_DIR
     #git clone git://github.com/phalcon/cphalcon.git
     cd $TARGET_DIR/cphalcon/build
     ./install
     cd ..
     cd ..
  fi
}

function install_svn()
{
  cd $TARGET_DIR/install
  if [! -d $TARGET_DIR/svn];then
    tar -zxvf $svn_version.tar.gz -C $TARGET_DIR
    cd $TARGET_DIR/$svn_version
    ./configure --with-ssl --prefix=$TARGET_DIR/svn --exec-prefix=$TARGET_DIR/svn
    make
    make install
    cd ..
  fi
}

function install_git()
{
  cd $TARGET_DIR/install
  if [ ! -d $TARGET_DIR/git ] ;then
     tar -jxvf $git_version.tar.bz2 -C $TARGET_DIR
     cd $TARGET_DIR/$git_version
     ./configure --prefix=$TARGET_DIR/git
     make
     make install
     cd ..
  fi
}

function init_env_var()
{
   cd ~
   echo '#mysql git php  #env_var'
   echo 'export MYSQL_HOME=$HOME/local/mysql'>>.bash_profile
   echo 'export GIT_HOME=$HOME/local/git'>>.bash_profile
   echo 'export PHP_HOME=$HOME/local/php'>>.bash_profile
   echo 'PATH=$MYSQL_HOME/bin:$GIT_HOME/bin:$PHP_HOME/bin:$PATH'>>.bash_profile
   source .bash_profile
}

init_env_var
