IPCLIENT="192.168.1.1"

# Centos 8

#disable selinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

#disable firewall
if service --status-all | grep -Fq "firewalld.service"; then
        systemctl stop firewalld
        systemctl disable firewalld
fi

#install freeradius
dnf install -y freeradius freeradius-utils

#change for start from root
sed -i 's/user = radiusd/user = root/' /etc/raddb/radiusd.conf 
sed -i 's/group = radiusd/group = root/' /etc/raddb/radiusd.conf 

#Enable pam
# was # pam
sed  -i 's/#\tpam/pam/' /etc/raddb/sites-available/default
ln -s /etc/raddb/mods-available/pam /etc/raddb/mods-enabled/pam

#Add client
cat >> /etc/raddb/clients.conf << EOF
client $IPCLIENT {
        ipaddr = $IPCLIENT
        secret = secret123
        require_message_authenticator = no
        nas_type = other
}
EOF

#Configure 'users'
# add string "DEFAULT Auth-Type := PAM" after  #DEFAULT    Group == "disabled", Auth-Type := Reject  
#TEXTBEFORE='Group == "disabled", Auth-Type := Reject'
NUM=$(grep -nr 'Group == "disabled", Auth-Type := Reject'  /etc/raddb/mods-config/files/authorize | awk -F: '{print $1}')
NUM=$((NUM+1))
sed -i ''$NUM'a\DEFAULT Auth-Type := PAM' /etc/raddb/mods-config/files/authorize



# starting freeradius
systemctl enable radiusd
systemctl start radiusd


# adding test user
useradd raduser
# set password
echo raduser:Password123 | chpasswd


#Use radtest from radiusd-util package using the local unix account, raduser.
radtest raduser Password123 localhost 0 testing123



#sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

#yum -y install pam-devel make gcc-c++ automake libtool
#cd ~
#git clone https://github.com/google/google-authenticator-libpam.git
#cd google-authenticator-libpam
#./bootstrap.sh
#./configure
#make
#sudo make install

