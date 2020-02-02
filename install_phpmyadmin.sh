

# install PHP 7.3
#Add PHP 7.3 Remi repository
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm 
sudo yum -y install epel-release yum-utils

#Disable repo for PHP 5.4
sudo yum-config-manager --disable remi-php54
sudo yum-config-manager --enable remi-php73

sudo yum -y install php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json
