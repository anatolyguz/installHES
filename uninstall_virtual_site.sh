#usage
#bash uninstall_virtual_site.sh


###SETTING BLOCK

DESTINATION="/opt/src"
BRANCH="master"

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


if [ -z "MYSQL_ROOT_PASSWORD" ]
then
    read -p "Enter mysql root password: " MYSQL_ROOT_PASSWORD
fi

#database name
if [ -z "$DATABASE_NAME" ]
then
    read -p "Enter mysql database name: " DATABASE_NAME
fi    
echo DATABASE_NAME = $DATABASE_NAME

#user account
if [ -z "$DATABASE_USER" ]
then
    read -p "Enter the name of user, the owner of our database: " DATABASE_USER
fi
echo DATABASE_USER = $DATABASE_USER


if [ -z "$MYSQL_ROOT_PASSWORD" ] 
then
    read -p "Enter MySQL root password (You installed it earlier): " MYSQL_ROOT_PASSWORD
fi
echo MYSQL_ROOT_PASSWORD = $MYSQL_ROOT_PASSWORD


SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

########################### end settings zone


####################################################################
# Get System Info
# https://github.com/coto/server-easy-install/blob/master/lib/core.sh
####################################################################
lowercase(){
	echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

shootProfile(){
	OS=`lowercase \`uname\``
	KERNEL=`uname -r`
	MACH=`uname -m`

	if [ "${OS}" == "windowsnt" ]; then
		OS=windows
	elif [ "${OS}" == "darwin" ]; then
		OS=mac
	else
		OS=`uname`
		if [ "${OS}" = "SunOS" ] ; then
			OS=Solaris
			ARCH=`uname -p`
			OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
		elif [ "${OS}" = "AIX" ] ; then
			OSSTR="${OS} `oslevel` (`oslevel -r`)"
		elif [ "${OS}" = "Linux" ] ; then
			if [ -f /etc/redhat-release ] ; then
				DistroBasedOn='RedHat'
				DIST=`cat /etc/redhat-release |sed s/\ release.*//`
				PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/SuSE-release ] ; then
				DistroBasedOn='SuSe'
				PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
				REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
			elif [ -f /etc/mandrake-release ] ; then
				DistroBasedOn='Mandrake'
				PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/debian_version ] ; then
				DistroBasedOn='Debian'
				if [ -f /etc/lsb-release ] ; then
			        	DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
			                PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
			                REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
            			fi
			fi
			if [ -f /etc/UnitedLinux-release ] ; then
				DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
			fi
			OS=`lowercase $OS`
			DistroBasedOn=`lowercase $DistroBasedOn`
		 	readonly OS
		 	readonly DIST
			readonly DistroBasedOn
		 	readonly PSUEDONAME
		 	readonly REV
		 	readonly KERNEL
		 	readonly MACH
		fi

	fi
}
shootProfile
#echo "OS: $OS"
#echo "DIST: $DIST"
#echo "PSUEDONAME: $PSUEDONAME"
#echo "REV: $REV"
#echo "DistroBasedOn: $DistroBasedOn"
#echo "KERNEL: $KERNEL"
#echo "MACH: $MACH"
#echo "========"
SUB_REV=${REV:0:1} 


# Remove Nginx config
#######################################################

PATH_TO_CONFIG_DOMAIN="/etc/nginx/conf.d"

if [[ $DIST == "Ubuntu" ]] 
    then  rm /etc/nginx/sites-enabled/$DOMAIN_NAME.conf
fi


rm $PATH_TO_CONFIG_DOMAIN/$DOMAIN_NAME.conf

rm /etc/nginx/certs/$DOMAIN_NAME.key
rm /etc/nginx/certs/$DOMAIN_NAME.crt 

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

