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
TEXTBEFORE='#DEFAULT    Group == "disabled", Auth-Type := Reject'
NUM=$(grep -nr "$TEXTBEFORE"  /etc/raddb/users | awk -F: '{print $1}')
NUM=$((NUM+1))
sed -i ''$NUM'a\DEFAULT Auth-Type := PAM' /etc/raddb/users



# starting freeradius
systemctl enable radiusd
systemctl start radiusd


# adding test user
useradd raduser --password Password123

#Use radtest from radiusd-util package using the local unix account, raduser.
radtest raduser Password123 localhost 0 testing123




