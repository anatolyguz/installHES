#Ubuntu 20

DOMAIN_NAME="sp.hideez.com"

apt-get update

# install nginx
apt install -y nginx

# install  PHP
apt install -y php-fpm

# install  PHP extensions:
# for view inslalled ext.
# php -m | head
# or phpinfo();
apt install -y php-dom php-mbstring php-curl php-zip unzip


#Download and install SimpleSAMLphp from github
sudo apt install -y nodejs npm

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
### --no-interaction
php composer.phar install 
npm install
npm run build


chown -R www-data.www-data /var/simplesamlphp/


 #Configuring Nginx

#create self sing. certificates
mkdir -p  /etc/pki/tls/certs
mkdir -p /etc/pki/tls/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/tls/private/sp.key -out /etc/pki/tls/certs/sp.crt  -subj "/CN=$DOMAIN_NAME"


#mkdir /var/www/$DOMAIN_NAME

cat > /etc/nginx/sites-available/$DOMAIN_NAME << EOF

server {
    listen 80;
    server_name $DOMAIN_NAME;
    return     301 https://\$host\$request_uri;
}

server {
        listen 443 ssl;
        server_name $DOMAIN_NAME;
        root /var/simplesamlphp;
        index index.html index.htm index.php;
        
        ssl_certificate        /etc/pki/tls/certs/sp.crt;
        ssl_certificate_key    /etc/pki/tls/private/sp.key;
        ssl_protocols          TLSv1.3 TLSv1.2;
        ssl_ciphers            EECDH+AESGCM:EDH+AESGCM;

        location ^~ /simplesaml {
            alias /var/simplesamlphp/www;

            location ~ ^(?<prefix>/simplesaml)(?<phpfile>.+?\.php)(?<pathinfo>/.*)?\$ {
                include          fastcgi_params;
                fastcgi_pass  unix:/var/run/php/php-fpm.sock;
                fastcgi_param SCRIPT_FILENAME \$document_root\$phpfile;

                # Must be prepended with the baseurlpath
                fastcgi_param SCRIPT_NAME /simplesaml\$phpfile;

                fastcgi_param PATH_INFO \$pathinfo if_not_empty;
            }
        }
    }

EOF


ln -s /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled/

systemctl reload   nginx.service 


# configuration: config.php

#sed -i  "s/'timezone' => null,/'timezone' => Europe\/Kiev, /"   test.txt



