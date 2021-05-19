#usage
#bash uninstall_virtual_site.sh

###SETTING BLOCK
#######################################
#If you want the script to ask no questions, un comment and fill in these variables
# (USER_PASSWORD must comply with mysql policy!)

#DOMAIN_NAME="hiddez.example.com"
DATABASE_NAME="db"
DATABASE_USER="user"
#MYSQL_ROOT_PASSWORD="mysqlrootpasswor"
#######################################


if [ -z "$MYSQL_ROOT_PASSWORD" ] 
then
    read -p "Enter MySQL root password: " MYSQL_ROOT_PASSWORD
fi
#echo MYSQL_ROOT_PASSWORD = $MYSQL_ROOT_PASSWORD
########################### end settings zone


###############################
# DETECT OS
d=$(dirname $0)
. ${d}/detectOS.sh

#echo "OS: $OS"
#echo "DIST: $DIST"
#echo "PSUEDONAME: $PSUEDONAME"
#echo "REV: $REV"
#echo "DistroBasedOn: $DistroBasedOn"
#echo "KERNEL: $KERNEL"
#echo "MACH: $MACH"
#echo "SUB_REV=$SUB_REV
#echo "========"

###############################

# Remove certificates
rm /etc/nginx/certs/hes.*
###############################

# Remove Nginx config
#######################################################
#PATH_TO_CONFIG_DOMAIN="/etc/nginx/conf.d"

if [[ $DIST == "Ubuntu" ]] ; then
    rm /etc/nginx/sites-enabled/$DOMAIN_NAME.conf
    rm /etc/nginx/sites-available/$DOMAIN_NAME.conf
fi

if [[ $DIST == "CentOS Linux" ]] ; then
    cp /etc/nginx/nginx.conf.default /etc/nginx/nginx.conf
fi
systemctl restart nginx

#######################################################


# Remove HES
#######################################################
HES_DIR=/opt/HES

systemctl stop HES.service
systemctl disable HES.service
rm /lib/systemd/system/HES.service 
rm -rf $HES_DIR
#######################################################

# Remove MySQL user and database
#######################################################
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DROP USER '$DATABASE_USER'@'127.0.0.1';"
DATABASE_NAME_FOR_MYSQL=$DATABASE_NAME
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE $DATABASE_NAME_FOR_MYSQL;"
#######################################################

echo finish!
