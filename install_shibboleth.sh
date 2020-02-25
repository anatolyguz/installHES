wget http://shibboleth.net/downloads/identity-provider/latest/shibboleth-identity-provider-3.4.6.tar.gz
tar xf shibboleth-identity-provider-3.4.6.tar.gz 

# edit .bash_profile with
# export JAVA_HOME=/usr/lib/jvm/jre-1.8.0
# PATH=$PATH:$HOME/bin:$JAVA_HOME/bin



shibboleth-identity-provider-3.4.6/bin/install.sh

#Create /etc/tomcat/Catalina/localhost/idp.xml with the following content:
echo '<Context docBase="/opt/shibboleth-idp/war/idp.war"
               unpackWAR="false"
               swallowOutput="true" />'  > /etc/tomcat/Catalina/localhost/idp.xml

#Make all files under /opt/shibboleth-idp owned by Tomcat:
chown -R tomcat.tomcat /opt/shibboleth-idp


# testing
#  http://test2idp.hideez.com:8080/idp/status
#  http://test2idp.hideez.com:8080/idp/shibboleth


ALTERNATIVE

yum install java-1.8.0-openjdk
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.16/bin/apache-tomcat-9.0.16.tar.gz
tar xfz apache-tomcat-9.0.16.tar.gz 
git clone https://anatolyguz@bitbucket.org/HideezDev/hideez-saml-idp.git

 #cd apache-tomcat-9.0.16



