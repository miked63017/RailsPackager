#!/bin/bash
export appname=$1

cat <<EOF > ./post-install.sh
#!/bin/bash

/etc/init.d/postgresql initdb
/etc/init.d/postgresql start
sudo -u postgres psql -c "CREATE USER showterm WITH PASSWORD 'showtermpassword';"
sudo -u postgres psql -c "CREATE DATABASE showterm;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE showterm to showterm;"
sed -i "s#ident#password#g" /var/lib/pgsql/data/pg_hba.conf
/etc/init.d/postgresql restart
cd /opt/$appname/var/www/showterm.io
/opt/$appname/usr/bin/bundle exec rake db:create db:migrate db:seed
chmod 777 /opt/$appname/var/www/showterm.io

EOF

chmod 777 post-install.sh
