#!/bin/bash
export appname=$1

export cwd=`pwd`
cd $cwd || exit 1
rm -rf opt
rm -rf etc
rm -rf ruby-*
rm post-install.sh

wget http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.1.tar.gz 
mkdir -p opt/$appname
tar -zxvf ruby-2.1.1.tar.gz 
cd ruby-2.1.1

./configure --program-suffix=2.1.1 --prefix=/opt/$appname/usr
make
make install DESTDIR=$cwd

ln -s $cwd/opt/$appname /opt/

cd ../
mkdir -p opt/$appname/var/www
/opt/$appname/usr/bin/gem2.1.1 install passenger
echo -e "\n\n\n\n" | /opt/$appname/usr/bin/passenger-install-apache2-module
/opt/$appname/usr/bin/gem2.1.1 install bundle
if [ -d "./showterm.io" ]; then
  cp -arvf showterm.io opt/$appname/var/www/
  cd opt/$appname/var/www/showterm.io
else
  cd opt/$appname/var/www
  git clone https://github.com/ConradIrwin/showterm.io
  cd showterm.io
fi
yum -y install postgresql postgresql-devel
/opt/$appname/usr/bin/gem2.1.1 install pg
/opt/$appname/usr/bin/bundle install

cd ../../../../../

cat << EOF >> opt/$appname/var/www/showterm.io/config/database.yml
---
development:
  adapter: postgresql
  encoding: unicode
  database: showterm
  pool: 5
  username: showterm
  password: showtermpassword
 
EOF

mkdir -p etc/httpd/conf.d/

cat << EOF >> etc/httpd/conf.d/00_passenger.conf
LoadModule passenger_module /opt/$appname/usr/lib/ruby/gems/2.1.0/gems/passenger-4.0.48/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
  PassengerRoot /opt/$appname/usr/lib/ruby/gems/2.1.0/gems/passenger-4.0.48
  PassengerDefaultRuby /opt/$appname/usr/bin/ruby2.1.1
</IfModule>

EOF

cat << EOF >> etc/httpd/conf.d/showterm.conf
RackEnv development
#PassengerAppRoot /opt/$appname/var/www/showterm.io/public

<VirtualHost *:80>
  ServerName showterm.whatever.com
  # !!! Be sure to point DocumentRoot to 'public'!
  DocumentRoot /opt/$appname/var/www/showterm.io/public    
  <Directory /opt/$appname/var/www/showterm.io/public>
    # This relaxes Apache security settings.
    AllowOverride all
    # MultiViews must be turned off.
    Options -MultiViews +Indexes
  </Directory>
</VirtualHost>

EOF
./create_post_install.sh $appname

fpm -s dir -t rpm -n "showterm-server" -v 1.0 --after-install ./post-install.sh -d postgresql -d postgresql-devel -d postgresql-server -d httpd -d httpd-devel -d nodejs -d nodejs-devel opt etc


