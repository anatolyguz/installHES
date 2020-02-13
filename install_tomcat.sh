#https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-7-on-centos-7-via-yum

sudo yum install tomcat -y

#sudo yum install tomcat-webapps tomcat-admin-webapps  -y

echo 'JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Xmx512m -XX:MaxPermSize=256m -XX:+UseConcMarkSweepGC"'  >>  /usr/share/tomcat/conf/tomcat.conf 



systemctl enable  tomcat
systemctl restart   tomcat
