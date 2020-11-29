#usage
#bash uninstall_virtual_site.sh

###SETTING BLOCK
#######################################
#If you want the script to ask no questions, un comment and fill in these variables
# (USER_PASSWORD must comply with mysql policy!)

#DOMAIN_NAME=""
#DATABASE_NAME=""
#DATABASE_USER=""
#MYSQL_ROOT_PASSWORD=""
#######################################

#domain name
if [ -z "$DOMAIN_NAME" ] 
then
    read -p "Enter domain name: " DOMAIN_NAME
fi

echo DOMAIN_NAME = $DOMAIN_NAME

#database name
if [ -z "$DATABASE_NAME" ]
then
    read -p "Enter mysql database name for drop: " DATABASE_NAME
fi    
echo DATABASE_NAME = $DATABASE_NAME

#user account
if [ -z "$DATABASE_USER" ]
then
    read -p "Enter the name of user for drop: " DATABASE_USER
fi
echo DATABASE_USER = $DATABASE_USER


if [ -z "$MYSQL_ROOT_PASSWORD" ] 
then
    read -p "Enter MySQL root password: " MYSQL_ROOT_PASSWORD
fi
echo MYSQL_ROOT_PASSWORD = $MYSQL_ROOT_PASSWORD


SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

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

rm /etc/nginx/certs/$DOMAIN_NAME.*
###############################



# Remove Nginx config
#######################################################

#PATH_TO_CONFIG_DOMAIN="/etc/nginx/conf.d"

if [[ $DIST == "Ubuntu" ]] ; then
    rm /etc/nginx/sites-enabled/$DOMAIN_NAME.conf
    rm /etc/nginx/sites-available/$DOMAIN_NAME.conf
fi

if [[ $DIST == "CentOS Linux" ]] ; then
    rm /etc/nginx/conf.d/$DOMAIN_NAME.conf
fi


systemctl restart nginx

#######################################################


# Remove HES
#######################################################
HES_DIR=/opt/HES/$DOMAIN_NAME

systemctl stop HES-$DOMAIN_NAME.service
systemctl disable HES-$DOMAIN_NAME.service
rm /lib/systemd/system/HES-$DOMAIN_NAME.service 
rm -rf $HES_DIR

#######################################################


# Remove MySQL user and database
#######################################################
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DROP USER '$DATABASE_USER'@'127.0.0.1';"
DATABASE_NAME_FOR_MYSQL=$DATABASE_NAME 
#if name of database base contains a character "-"
# then the name of the base must be enclosed in reverse apostrophe
if [[ "$DATABASE_NAME" == *"-"* ]]; then
  DATABASE_NAME_FOR_MYSQL="\`$DATABASE_NAME\`"
fi

mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE $DATABASE_NAME_FOR_MYSQL;"

#######################################################


echo finish!
