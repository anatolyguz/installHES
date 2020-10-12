yum update -y
yum install nano -y
yum install mc -y 
yum install telnet -y 
yum install bash-completion -y
yum install wget -y


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
echo "PS1='\[\e[1;31m\][\u@\h \W]\$\[\e[0m\] '" >> .bashrc 


. ~/.bashrc

