IPCLIENT="192.168.1.1"

# Centos 7

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
systemctl stop firewalld
systemctl disable firewalld
yum install -y freeradius freeradius-utils

sed -i 's/user = radiusd/user = root/' /etc/raddb/radiusd.conf 
sed -i 's/group = radiusd/group = root/' /etc/raddb/radiusd.conf 

#Enable pam
# was # pam
sed  -i 's/#\tpam/pam/' /etc/raddb/sites-enabled/default
ln -s /etc/raddb/mods-available/pam /etc/raddb/mods-enabled/pam

