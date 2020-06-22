# usage  
# bash istall_commom.sh


####################################################################
# Centos 7
####################################################################
install_CenOS_7(){

echo updating system...
yum update -y

#Installing git
yum install git -y

#disabling SELinux:
sed  -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
sed  -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 

setenforce 0


# Adding Microsoft Package Repository and Installing .NET Core:
echo Adding Microsoft Package Repository and Installing .NET Core:
#rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm
rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm

yum install dotnet-sdk-3.1 -y

# Adding MySQL Package Repository and Installing MySQL Server:
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
yum install mysql-server -y

# Set parameter Enabling lower_case_table_names  to 1
# Before run the mysql server, add lower_case_table_names=1
# echo "lower_case_table_names=1" >> /etc/my.cnf 


#Enabling and running MySQL Service
systemctl restart mysqld.service
systemctl enable mysqld.service

# Postinstalling and Securing MySQL Server

#After install mysql roots temp. password stored in /var/log/mysqld.log
MYSQL_PASSWORD_AFTER_INSTALL=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $13}')
echo MYSQL_PASSWORD_AFTER_INSTALL = $MYSQL_PASSWORD_AFTER_INSTALL

#Change root password
mysql --connect-expired-password  -u root -p"$MYSQL_PASSWORD_AFTER_INSTALL" -e  "alter user 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD';"


#analog  mysql_secure_installation
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
delete from mysql.user where user='' and host = 'localhost';
delete from mysql.user where user='' and host = 'localhost.localdomain';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
FLUSH PRIVILEGES;
EOF


# Installing EPEL Repository and Nginx
yum install epel-release -y
yum install nginx -y

}
####################################################################





####################################################################
# Centos 8
####################################################################
install_CenOS_8(){

echo updating system...
dnf update -y

#Installing git
dnf install git -y

#disabling SELinux:
sed  -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
sed  -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 

setenforce 0

# Installing dotnet:
dnf install dotnet-sdk-3.1

# Installing MySQL Server:
dnf install mysql-server -y

#Enabling and running MySQL Service
systemctl restart mysqld.service
systemctl enable mysqld.service

# Postinstalling and Securing MySQL Server

#After install mysql roots temp. password stored in /var/log/mysqld.log
MYSQL_PASSWORD_AFTER_INSTALL=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $13}')
echo MYSQL_PASSWORD_AFTER_INSTALL = $MYSQL_PASSWORD_AFTER_INSTALL

#Change root password
mysql --connect-expired-password  -u root -p"$MYSQL_PASSWORD_AFTER_INSTALL" -e  "alter user 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD';"

#analog  mysql_secure_installation
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
delete from mysql.user where user='' and host = 'localhost';
delete from mysql.user where user='' and host = 'localhost.localdomain';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
FLUSH PRIVILEGES;
EOF


# Installing  Nginx
dnf install nginx -y

}
####################################################################


lowercase(){
	echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

####################################################################
# Get System Info
# https://github.com/coto/server-easy-install/blob/master/lib/core.sh
####################################################################
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
if [[ $DIST == "CentOS Linux" ]]  && [[ $SUB_REV  == "7" ]]
  then install_CenOS_7
#elif [[ $DIST == "Ubuntu" ]]
#  then install_Ubuntu
fi

if [[ $DIST == "CentOS Linux" ]]  && [[ $SUB_REV  == "8" ]]
  then install_CenOS_8
fi




###SETTING BLOCK

MYSQL_ROOT_PASSWORD=""
# need strong passsword
# repeats until you meet the requirements
#until [[ ${#MYSQL_ROOT_PASSWORD} -ge 9 ]] && [[ "$MYSQL_ROOT_PASSWORD" =~ [A-Z] ]] && [[ "$MYSQL_ROOT_PASSWORD" =~ [a-z] ]] &&  [[ "$MYSQL_ROOT_PASSWORD" =~ [0-9] ]] &&  [[ "$MYSQL_ROOT_PASSWORD" =~ [@#$%\&*+=-] ]] 
until [[ ${#MYSQL_ROOT_PASSWORD} -ge 9 ]] && [[ "$MYSQL_ROOT_PASSWORD" =~ [A-Z] ]] && [[ "$MYSQL_ROOT_PASSWORD" =~ [a-z] ]] &&  [[ "$MYSQL_ROOT_PASSWORD" =~ [0-9] ]]  
do
   read -p "Enter strong mysql root password (at least 8, upper and lowercase letters, numbers, and special characters) : " MYSQL_ROOT_PASSWORD
done  

#echo MYSQL_ROOT_PASSWORD = $MYSQL_ROOT_PASSWORD

#SETCOLOR_SUCCESS="echo -en \\033[1;32m"
#SETCOLOR_FAILURE="echo -en \\033[1;31m"
#SETCOLOR_NORMAL="echo -en \\033[0;39m"

########################### end settings zone




systemctl enable nginx
systemctl restart nginx



#save setting to file
FILE_SETTING=$HOME/install_common_setting.txt
if [ -f $FILE_SETTING ]; then
    mv $HOME/install_common_setting.txt $HOME/install_common_setting-$(date +%Y-%m-%d-%H-%M-%S).txt
fi

cat > $HOME/install_common_setting.txt << EOF
MYSQL_ROOT_PASSWORD = $MYSQL_ROOT_PASSWORD
EOF


echo "In your home directory, has been created file install_common_setting.txt with your mysql root's password."
echo "For your safety, after making sure everything works, it is advised to save your settings somewhere and delete this file"

cat $HOME/install_common_setting.txt

echo "You need to restart to work on"
