#Ubuntu 20


DOMAIN_NAME="sp.hideez.com"

# install nginx
apt install nginx

# install  PHP
sudo apt install php-fpm

# install  PHP extensions:
# for view inslalled ext.
# php -m | head
# or phpinfo();
apt install php-dom php-mbstring php-curl php-zip unzip





mkdir /var/www/$DOMAIN_NAME


cat > /etc/nginx/sites-available/$DOMAIN_NAME << EOF
server {
    listen 80;
    server_name $DOMAIN_NAME www.$DOMAIN_NAME;
    root /var/www/$DOMAIN_NAME;

    index index.html index.htm index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
     }

    location ~ /\.ht {
        deny all;
    }

}
EOF

ln -s /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled/




#Download and install SimpleSAMLphp from github
sudo apt install nodejs npm

cd /var
git clone https://github.com/simplesamlphp/simplesamlphp.git  simplesamlphp

cd /var/simplesamlphp
cp -r config-templates/* config/
cp -r metadata-templates/* metadata/


# Install composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"


#Install the external dependencies with Composer
php composer.phar install
npm install
npm run build




#Add PHP 7.3 Remi repository
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm 
yum -y install epel-release yum-utils

#Disable repo for PHP 5.4
yum-config-manager --disable remi-php54
yum-config-manager --enable remi-php73

yum -y install php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json

#enable and restart  php-fpm.service
systemctl enable  php-fpm
systemctl restart php-fpm

# install phpMyAdmin

yum -y  install epel-release
yum -y install phpmyadmin

cat > /etc/nginx/conf.d/phpmyadmin.conf << EOF
server {
  location /phpMyAdmin {
         root /usr/share/;
         index index.php index.html index.htm;
         location ~ ^/phpMyAdmin/(.+\.php)\$ {
                 try_files \$uri = 404;
                 root /usr/share/;
                 #fastcgi_pass unix:/run/php-fpm/www.sock;
                 fastcgi_pass 127.0.0.1:9000;
                 fastcgi_index index.php;
                 fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                include /etc/nginx/fastcgi_params;
         }
         location ~* ^/phpMyAdmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))\$ {
                 root /usr/share/;
         }
  }
  location /phpmyadmin {
      rewrite ^/* /phpMyAdmin last;
  }
}
EOF

#Open mySQL for all ip
echo "bind-address = 0.0.0.0" >> /etc/my.cnf 


read -p "Enter MySQL root password: " MYSQL_ROOT_PASSWORD
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "use mysql; UPDATE user SET Host='%' WHERE User='root' AND Host='localhost'; FLUSH PRIVILEGES;"

mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD';"


if [ $? -eq 0 ]; then
  echo Good
else
  echo no Good
fi

systemctl restart mysqld
systemctl reload nginx

#chown nginx:nginx /var/lib/php/session/
#chown -R nginx:nginx /usr/share/phpMyAdmin/
chmod 777  /var/lib/php/session/




#nano /etc/php-fpm.d/www.conf 
#listen.owner = nginx
#listen.group = nginx

#ALTER USER 'user_name'@'localhost' IDENTIFIED WITH mysql_native_password BY 'your_password'; 






