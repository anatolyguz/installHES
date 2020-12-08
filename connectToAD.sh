
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





####################################################################
# Ubuntu 18.04
# https://computingforgeeks.com/join-ubuntu-debian-to-active-directory-ad-domain/
####################################################################

join_Ubuntu_18_04(){

  hostnamectl set-hostname $HOSTNAME.$DOMAINNAME 

  # confirm
  hostnamectl status

  echo 127.0.0.1  $HOSTNAME.$DOMAINNAME $HOSTNAME | sudo tee -a  /etc/hosts
  echo $DCIP $DC.$DOMAINNAME $DC | sudo tee -a /etc/hosts

 
  systemctl stop systemd-resolved
  systemctl disable systemd-resolved
  unlink /etc/resolv.conf
  echo nameserver $DNS1 | sudo tee /etc/resolv.conf
 
  apt -y install realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit

  # For testing  
  realm discover $DOMAINNAME

  realm join $DOMAINNAME

  #for test 
  realm list
  # for test 
  id administrator@$DOMAINNAME
  # for test 

}

join_Ubuntu_18_04