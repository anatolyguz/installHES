#!/bin/bash

#############################################
#    USAGE:
#         sudo bash installCommon.sh
#    or make this file executable:
#         chmode +x installCommon.sh
#    and run it:
#         sudo ./installCommon.sh
#############################################



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

# Firewall Configuration:
if systemctl list-unit-files | grep -Fq firewalld; then
 firewall-cmd --zone=public --permanent --add-port=22/tcp
 firewall-cmd --zone=public --permanent --add-port=80/tcp
 firewall-cmd --zone=public --permanent --add-port=443/tcp
 firewall-cmd --reload
fi


# Adding Microsoft Package Repository and Installing .NET Core:
echo Adding Microsoft Package Repository and Installing .NET Core:
rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm

yum install dotnet-sdk-3.1 -y

# Adding MySQL Package Repository and Installing MySQL Server:
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
yum install mysql-server -y


#Enabling and running MySQL Service
systemctl restart mysqld.service
systemctl enable mysqld.service


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

# Firewall Configuration:
if systemctl list-unit-files | grep -Fq firewalld; then
 firewall-cmd --zone=public --permanent --add-port=22/tcp
 firewall-cmd --zone=public --permanent --add-port=80/tcp
 firewall-cmd --zone=public --permanent --add-port=443/tcp
fi


# Installing dotnet:
dnf install dotnet-sdk-3.1

# Installing MySQL Server:
dnf install mysql-server -y

#Enabling and running MySQL Service
systemctl restart mysqld.service
systemctl enable mysqld.service


# Installing  Nginx
dnf install nginx -y

}
####################################################################





####################################################################
# Ubuntu 18.04
####################################################################
install_Ubuntu_18_04(){

echo updating system...
apt update
apt upgrade -y

#Installing git
apt install git -y


# Firewall Configuration:
ufw allow 22
ufw allow 80
ufw allow 443

# Installing dotnet:
wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update
apt install dotnet-sdk-3.1 -y

# Installing MySQL Server:
DEBPKG="mysql-apt-config_0.8.16-1_all.deb"
wget -c https://dev.mysql.com/get/$DEBPKG
dpkg -i $DEBPKG
apt update
apt install mysql-server -y

# Installing  Nginx
apt install nginx -y
}
####################################################################



####################################################################
# Ubuntu 20.04
####################################################################
install_Ubuntu_20_04(){

echo updating system...
apt update
apt upgrade -y

#Installing git
apt install git -y

# Installing dotnet:
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update
apt install dotnet-sdk-3.1 -y

# Installing MySQL Server:
apt install mysql-server -y

# Installing  Nginx
apt install nginx -y

}
####################################################################


# DETECT OS
# "detectOS.sh"  - this script MUST be in the same directory as the installHES.sh file

DIRNAME=$(dirname $0)
if [ ! -f $DIRNAME/detectOS.sh ] ; then
  echo "there is no detectOS.sh file in the script directory" 
  exit 1
fi
. $DIRNAME/detectOS.sh
echo Detect OS:
echo DIST = $DIST
echo REV = $REV
echo SUB_REV = $SUB_REV

##############################################################



########################### end settings zone

if [[ $DIST == "CentOS Linux" ]]  && [[ $SUB_REV  == "7" ]]
  then install_CenOS_7
fi

if [[ $DIST == "CentOS Linux" ]]  && [[ $SUB_REV  == "8" ]]
  then install_CenOS_8
fi

if [[ $DIST == "Ubuntu" ]]  && [[ $REV  == "18.04" ]]
  then install_Ubuntu_18_04
fi

if [[ $DIST == "Ubuntu" ]]  && [[ $REV  == "20.04" ]]
  then install_Ubuntu_20_04 
fi


systemctl enable nginx
systemctl restart nginx


echo "You need to restart to work on"
