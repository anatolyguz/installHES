install_CenOS_7(){
  yum update -y
  yum install nano -y
  yum install mc -y 
  yum install telnet -y 
  yum install bash-completion -y
  yum install wget -y
}
####################################################################
install_CenOS_8(){
  dnf update -y
  dnf install nano -y
  dnf install mc -y 
  dnf install telnet -y 
  dnf install bash-completion -y
  dnf install wget -y
}
####################################################################

lowercase(){
	echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

####################################################################

####################################################################
# Get System Info
# https://github.com/coto/server-easy-install/blob/master/lib/core.sh
####################################################################
shootProfile(){
	OS=`lowercase \`uname\``
	KERNEL=`uname -r`
	MACH=`uname -m`

	if [ "${OS}" == "windowsnt" ]; then
		OS=windows
	elif [ "${OS}" == "darwin" ]; then
		OS=mac
	else
		OS=`uname`
		if [ "${OS}" = "SunOS" ] ; then
			OS=Solaris
			ARCH=`uname -p`
			OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
		elif [ "${OS}" = "AIX" ] ; then
			OSSTR="${OS} `oslevel` (`oslevel -r`)"
		elif [ "${OS}" = "Linux" ] ; then
			if [ -f /etc/redhat-release ] ; then
				DistroBasedOn='RedHat'
				DIST=`cat /etc/redhat-release |sed s/\ release.*//`
				PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/SuSE-release ] ; then
				DistroBasedOn='SuSe'
				PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
				REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
			elif [ -f /etc/mandrake-release ] ; then
				DistroBasedOn='Mandrake'
				PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
			elif [ -f /etc/debian_version ] ; then
				DistroBasedOn='Debian'
				if [ -f /etc/lsb-release ] ; then
			        	DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
			                PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
			                REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
            			fi
			fi
			if [ -f /etc/UnitedLinux-release ] ; then
				DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
			fi
			OS=`lowercase $OS`
			DistroBasedOn=`lowercase $DistroBasedOn`
		 	readonly OS
		 	readonly DIST
			readonly DistroBasedOn
		 	readonly PSUEDONAME
		 	readonly REV
		 	readonly KERNEL
		 	readonly MACH
		fi

	fi
}
shootProfile
#echo "OS: $OS"
#echo "DIST: $DIST"
#echo "PSUEDONAME: $PSUEDONAME"
#echo "REV: $REV"
#echo "DistroBasedOn: $DistroBasedOn"
#echo "KERNEL: $KERNEL"
#echo "MACH: $MACH"
#echo "========"
SUB_REV=${REV:0:1} 


if [[ $DIST == "CentOS Linux" ]]  && [[ $SUB_REV  == "7" ]]
  then install_CenOS_7
#elif [[ $DIST == "Ubuntu" ]]
#  then install_Ubuntu
fi

if [[ $DIST == "CentOS Linux" ]]  && [[ $SUB_REV  == "8" ]]
  then install_CenOS_8
fi




#Colour nano
cat > ~/.nanorc << EOF
include /usr/share/nano/java.nanorc
include /usr/share/nano/debian.nanorc
include /usr/share/nano/makefile.nanorc
include /usr/share/nano/objc.nanorc
include /usr/share/nano/mgp.nanorc
include /usr/share/nano/ruby.nanorc
include /usr/share/nano/asm.nanorc
include /usr/share/nano/php.nanorc
include /usr/share/nano/tcl.nanorc
include /usr/share/nano/groff.nanorc
include /usr/share/nano/tex.nanorc
include /usr/share/nano/sh.nanorc
include /usr/share/nano/patch.nanorc
include /usr/share/nano/c.nanorc
include /usr/share/nano/css.nanorc
include /usr/share/nano/gentoo.nanorc
include /usr/share/nano/python.nanorc
include /usr/share/nano/xml.nanorc
include /usr/share/nano/ocaml.nanorc
include /usr/share/nano/cmake.nanorc
include /usr/share/nano/html.nanorc
include /usr/share/nano/fortran.nanorc
include /usr/share/nano/mutt.nanorc
include /usr/share/nano/man.nanorc
include /usr/share/nano/pov.nanorc
include /usr/share/nano/nanorc.nanorc
include /usr/share/nano/perl.nanorc
include /usr/share/nano/awk.nanorc
EOF

#Colour console promt
echo "PS1='\[\e[1;31m\][\u@\h \W]\\$\[\e[0m\] '" >> .bashrc 

. ~/.bashrc

