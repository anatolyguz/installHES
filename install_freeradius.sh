
# for Centos 8


# disable selinux and firewall 
#############################################################
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

#disable firewall
#if service --status-all | grep -Fq "firewalld.service"; then
if systemctl list-unit-files | grep -Fq firewalld; then
        systemctl stop firewalld
        systemctl disable firewalld
fi
# end disable selinux and firewall 
#############################################################


# time synchronization
if systemctl list-unit-files | grep -Fq chronyd; then
        systemctl enable  chronyd
        systemctl restart  chronyd
fi
#############################################################


#install freeradius
#############################################################
# any customer (for testing)
IPCLIENT="192.168.1.1"

dnf install -y freeradius freeradius-utils

#freeRADIUS must run as root to access the .google_authenticator in user home directories.
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
#### 
#  ATTENTION!
#  All instructions say that you need to change the file /etc/raddb/users
#  but actually now this file is just a link to /etc/raddb/mods-config/files/authorize
####

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
# end install freeradius
#############################################################



###   install google-authenticator
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y install google-authenticator qrencode
# end install google-authenticator
########################################################


#### or the same from source
########################################################
#yum -y install pam-devel make gcc-c++ automake libtool
#cd ~
#git clone https://github.com/google/google-authenticator-libpam.git
#cd google-authenticator-libpam
#./bootstrap.sh
#./configure
#make
#sudo make install
# end install google-authenticator
########################################################



# join to Active Directory
########################################################
DOMAINNAME="mydomain.com"
# Name of domain controler:
DC="DC1"  
# ip address of domain controler:
DCIP="192.168.1.1"

# The first dns should be a domain controler:
DNS1=$DCIP
DNS2="192.168.1.2"


NAMEINTERFACE=$(ip route get 8.8.8.8 | awk '{ print $5; exit }')
echo PEERDNS="no" >> /etc/sysconfig/network-scripts/ifcfg-$NAMEINTERFACE 
echo "DNS1="$DNS1 >> /etc/sysconfig/network-scripts/ifcfg-$NAMEINTERFACE 
echo "DNS2="$DNS2 >> /etc/sysconfig/network-scripts/ifcfg-$NAMEINTERFACE 

systemctl restart  NetworkManager.service

echo 127.0.0.1  $HOSTNAME.$DOMAINNAME $HOSTNAME >> /etc/hosts
echo $DCIP $DC.$DOMAINNAME $DC >> /etc/hosts 
#echo $DCIP $DOMAINNAME >> /etc/hosts 


#/etc/sysconfig/network-scripts/ifcfg-ens192 

# For testing  
realm discover $DOMAINNAME

#dnf -y install sssd realmd adcli
dnf -y install oddjob oddjob-mkhomedir sssd adcli
realm join $DOMAINNAME

#for test 
realm list
# for test 
id administrator@$DOMAINNAME
# for test 


# I don't know why, 
#but with the "access_provider = ad", my radius authorization doesn't work
# so it should be here 
# access_provider = simple
# ( or completely commented )  :
sed -i 's/access_provider = ad/#access_provider = ad/' /etc/sssd/sssd.conf
systemctl restart sssd



PASSWORD="password"
radtest administrator@$DOMAINNAME  $PASSWORD  localhost 0 testing123

#realm permit -g vpnusers
#realm permit -a
# end join to Active Directory
########################################################


########################################################
# enable two-factor authorization in radius:
cat > /etc/pam.d/radiusd << EOF
auth       requisite    pam_google_authenticator.so forward_pass
auth       required     pam_sss.so use_first_pass
account    required     pam_nologin.so
account    include      password-auth
session    include      password-auth
EOF
systemctl restart radiusd
########################################################



# if you need two-factor authentication for ssh too,you need to do the following:
#Add the following line to the top 
#   auth required pam_google_authenticator.so nullok
#of the file. /etc/pam.d/sshd
sed -i '1a\auth required pam_google_authenticator.so nullok' /etc/pam.d/sshd 

# set ChallengeResponseAuthentication value to yes in /etc/ssh/sshd_config:
sed -i 's/#ChallengeResponseAuthentication yes/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/ChallengeResponseAuthentication no/#ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd



