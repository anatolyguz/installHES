install_CenOS_7(){
  yum update -y
  yum install nano -y
  yum install mc -y 
  yum install telnet -y 
  yum install bash-completion -y
  yum install wget -y
  yum install unzip -y
  
}
####################################################################
install_CenOS_8(){
  dnf update -y
  dnf install nano -y
  dnf install mc -y 
  dnf install telnet -y 
  dnf install bash-completion -y
  dnf install wget -y
  dnf install unzip -y
  
}
####################################################################

####################################################################
install_Ubuntu(){
  apt update
  apt upgrade -y
  apt install install mc -y 
  apt install install unzip -y 
}
####################################################################


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


if [[ $DIST == "CentOS Linux" ]]  && [[ $SUB_REV  == "7" ]]
  then install_CenOS_7
fi

if [[ $DIST == "CentOS Linux" ]]  && [[ $SUB_REV  == "8" ]]
  then install_CenOS_8
fi

if [[ $DIST == "Ubuntu" ]]
  then install_Ubuntu
fi




#Colour nano
# get from 
#https://github.com/scopatz/nanorc
curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh



#Colour console promt
echo "PS1='\[\e[1;31m\][\u@\h \W]\\$\[\e[0m\] '" >> .bashrc 

. ~/.bashrc

