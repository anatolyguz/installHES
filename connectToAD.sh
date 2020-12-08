
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






join_Ubuntu_18_04(){
####################################################################
# Ubuntu 18.04
# https://computingforgeeks.com/join-ubuntu-debian-to-active-directory-ad-domain/
####################################################################

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




join_CentOS_8() {

#################################################################################
#https://computingforgeeks.com/join-centos-rhel-system-to-active-directory-domain/
#################################################################################
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

}


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


if [[ $DIST == "CentOS Linux" ]]  && [[ $SUB_REV  == "8" ]]
  join_CentOS_8
fi

if [[ $DIST == "Ubuntu" ]]  && [[ $REV  == "18.04" ]]
  then join_Ubuntu_18_04
fi

