# usage  
# bash istall_commom.sh

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


echo updating system...
yum update -y

#Installing and cloning the HES GitHub repository
yum install git -y
cd /opt
git clone https://github.com/HideezGroup/HES src

#disabling SELinux:
sed  -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
sed  -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 

setenforce 0


# Adding Microsoft Package Repository and Installing .NET Core:
echo Adding Microsoft Package Repository and Installing .NET Core:
rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm
yum install dotnet-sdk-2.2 -y

# Adding MySQL Package Repository and Installing MySQL Server:
rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
yum install mysql-server -y


# Set parameter Enabling lower_case_table_names  to 1
# Before run the mysql server, add lower_case_table_names=1
echo "lower_case_table_names=1" >> /etc/my.cnf 


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
