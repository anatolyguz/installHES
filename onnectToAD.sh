
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
####################################################################
join_Ubuntu_18_04(){

  apt install resolvconf
  systemctl enable resolvconf.service
  echo nameserver $DNS1 >> /etc/resolvconf/resolv.conf.d/head
  
  
  
  apt install -y realmd

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
  apt install -y oddjob oddjob-mkhomedir sssd adcli
  
  apt install -y sssd-tools sssd libnss-sss libpam-sss adcli
  realm join $DOMAINNAME

  #for test 
  realm list
  # for test 
  id administrator@$DOMAINNAME
  # for test 

}



 join_Ubuntu_18_04
