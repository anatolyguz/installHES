#!/bin/bash

#############################################
#    USAGE:
#         sudo bash installHES.sh
#    or make this file executable:
#         chmode +x installHES.sh
#    and run it:
#         sudo ./installHES.sh
#############################################

###SETTING BLOCK

REPO="https://github.com/HideezGroup/HES"
DESTINATION="/opt/src/HES"
BRANCH="master"
VERSION="release"
TAG="HEAD"
#######################################
# If you want the script to ask no questions, un comment and fill in these variables
# (USER_PASSWORD must comply with mysql policy!)
#DOMAIN_NAME=""
#USER_PASSWORD=""
#SMTP_HOST=""
#SMTP_PORT=""
#SMTP_USER_NAME=""
#SMTP_PASSWORD=""
#MYSQL_ROOT_PASSWORD=""
#######################################


#############################################################
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



if [ -z "$MYSQL_ROOT_PASSWORD" ] 
then
    read -p "Enter MySQL root password (You installed it earlier): " MYSQL_ROOT_PASSWORD
fi
echo MYSQL_ROOT_PASSWORD = $MYSQL_ROOT_PASSWORD


#domain name
if [ -z "$DOMAIN_NAME" ] 
then
    read -p "Enter domain name (or leave it blank for use hideez.example.com): " item
    DOMAIN_NAME="${item:-hideez.example.com}"
fi

echo DOMAIN_NAME = $DOMAIN_NAME

if [ -z "$USER_PASSWORD" ] 
then
  read -p "Enter password for new MySQL user : " USER_PASSWORD
fi

echo USER_PASSWORD = $USER_PASSWORD

if [ -z "$SMTP_HOST" ]
then
    read -p "Enter SMTP host: " SMTP_HOST
fi
echo SMTP_HOST = $SMTP_HOST

if [ -z "$SMTP_PORT" ] 
then
    read -p "Enter SMTP port: " SMTP_PORT
fi
echo SMTP_PORT = $SMTP_PORT

if [ -z "$SMTP_USER_NAME" ] 
then
    read -p "Enter SMTP UserName: " SMTP_USER_NAME
fi
echo SMTP_USER_NAME = $SMTP_USER_NAME

if [ -z "$SMTP_PASSWORD" ] 
then
    read -p "Enter SMTP Password: " SMTP_PASSWORD
fi
echo SMTP_PASSWORD = $SMTP_PASSWORD


########################### end settings zone



#create backup src
if [ -d $DESTINATION ]; then
    mv $DESTINATION $DESTINATION-$(date +%Y-%m-%d-%H-%M-%S)
fi

#Cloning the HES GitHub repository

git clone $REPO -b $BRANCH $DESTINATION

if [ $? -eq 0 ]; then
  echo "repository successfully cloned"
else
  # ups....
  echo "error cloning repository" 
  exit 1
fi

cd $DESTINATION
git checkout $TAG

# Version HES
VERSION_HES=$(grep '<Version>.*</Version>' $DESTINATION/HES.Web/HES.Web.csproj | sed   's/.*<Version>\(.*\)<\/Version>.*/\1/')


#Creating MySQL User
DATABASE_USER="user"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$DATABASE_USER'@'127.0.0.1' IDENTIFIED BY '$USER_PASSWORD';"

if [ $? -eq 0 ]; then
  echo "sql user successfully created (or updated)"
else
  # ups.... 
  echo "error creating mysql user"
  exit 1
fi


#Creating MySQL Database for the Hideez Enterprise Server
DATABASE_NAME="db"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;
GRANT ALL ON $DATABASE_NAME.* TO '$DATABASE_USER'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ]; then
  echo "databse successfully created (or updated)"
else
  # ups.... 
  echo "error creating mysql database db"
  exit 1
fi


################################
 
#Building the Hideez Enterprise Server from the sources
 
HES_DIR=/opt/HES
BACKUP_HES_DIR=$HES_DIR-$(date +%Y-%m-%d-%H-%M-%S)

if [ -d $HES_DIR ]; then
    # try stop service
    systemctl stop HES.service
    mv $HES_DIR $BACKUP_HES_DIR
fi

cd $DESTINATION/HES.Web/
mkdir $HES_DIR
dotnet publish -c $VERSION -v d -o $HES_DIR --runtime linux-x64 HES.Web.csproj
if [ $? -eq 0 ]; then
  echo "the application was compiled successfully"
else
  # ups.... 
  echo "application compilation error"
  exit 1
fi

cp $DESTINATION/HES.Web/Crypto_linux.dll $HES_DIR/Crypto.dll

if [ $? -eq 0 ]; then
  echo "Libraries successfully copied"
else
  # ups.... 
  echo "Error copying libraries"
  exit 1
fi


# Create appsettings.production.json
cp $HES_DIR/appsettings.json $HES_DIR/appsettings.Production.json
if [ $? -eq 0 ]; then
  echo "appsettings.json to appsettings.Production.json successfully copied"
else
  # ups.... 
  echo "Error copying appsettings.Production.json"
  exit 1
fi

JSON=$HES_DIR/appsettings.Production.json
BACKUP_JSON=$BACKUP_HES_DIR/appsettings.Production.json

# change setting in  appsettings.json
# Default string is
# "DefaultConnection": "server=127.0.0.1;port=3306;database=db;uid=user;pwd=password"

sed -i 's/uid=user;pwd=password/uid=user;pwd='$USER_PASSWORD'/' $JSON

sed -i 's/"Host": "smtp.example.com"/"Host": "'$SMTP_HOST'"/' $JSON
sed -i 's/"Port": 123/"Port": '$SMTP_PORT'/' $JSON
sed -i 's/"UserName": "user@example.com"/"UserName": "'$SMTP_USER_NAME'"/' $JSON
sed -i 's/"Password": "password"/"Password": "'$SMTP_PASSWORD'"/' $JSON


#Fido2 setting
# Default strings is
# "Fido2": {
#    "ServerDomain": "example.com",
#    "ServerName": "HES",
#    "Origin": "https://example.com",
#    "TimestampDriftTolerance": 300000,
#    "MDSAccessKey": null
#  },
sed -i 's/"ServerDomain": "example.com"/"ServerDomain": "'$DOMAIN_NAME'"/' $JSON
sed -i 's#"Origin": "https://example.com"#"Origin": "https://'$DOMAIN_NAME'"#' $JSON


# ServerSettings setting
# Default strings is
#"ServerSettings": {
#    "Name": "HES",
#    "Url": "https://example.com"
#  },
sed -i 's#"Url": "https://example.com"#"Url": "https://'$DOMAIN_NAME'"#' $JSON


# Saml2 setting
#"Saml2": {
#   "Issuer": "https://example.com",
#   "SingleSignOnDestination": "https://example.com/Saml/Login",
#   "SingleLogoutDestination": "https://example.com/Saml/Logout",
#   "SignatureAlgorithm": "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256",
#   "SigningCertificateFile": "pathToPfx",
#   "SigningCertificatePassword": "",
#   "CertificateValidationMode": "None",
#   "RevocationMode": "NoCheck"
#  },

PFX_PASSWORD="1234"

sed -i 's#"Issuer": "https://example.com"#"Issuer": "https://'$DOMAIN_NAME'"#' $JSON
sed -i 's#"SingleSignOnDestination": "https://example.com/Saml/Login"#"SingleSignOnDestination": "https://'$DOMAIN_NAME'/Saml/Login"#' $JSON
sed -i 's#"SingleLogoutDestination": "https://example.com/Saml/Logout"#"SingleLogoutDestination": "https://'$DOMAIN_NAME'/Saml/Logout"#' $JSON
sed -i 's#"SigningCertificateFile": "pathToPfx"#"SigningCertificateFile": "saml.pfx"#' $JSON
sed -i 's#"SigningCertificatePassword": ""#"SigningCertificatePassword": "'$PFX_PASSWORD'"#' $JSON


# Saml2Sp setting
#"Saml2Sp": {
#  "RelyingParties": [
#    {
#      "Metadata": "https://example.com/saml/sp/metadata"
#    }
#  ]
#},
sed -i 's#"Metadata": "https://example.com/saml/sp/metadata"#"Metadata": "https://'$DOMAIN_NAME'/saml/sp/metadata"#' $JSON


################################
#creating certificate for SAML
openssl req -newkey rsa:3072 -new -x509 -days 3652 -nodes -out $HES_DIR/saml.crt -keyout $HES_DIR/saml.pem  -subj "/CN=$DOMAIN_NAME"
openssl pkcs12 -inkey $HES_DIR/saml.pem -in $HES_DIR/saml.crt -export -out $HES_DIR/saml.pfx -passout pass:$PFX_PASSWORD

################################


# if exist backup of appsettings, then resore it
if [ -f $BACKUP_JSON ]; then
    cp $BACKUP_JSON  $JSON
    if [ $? -eq 0 ]; then
        echo "appsettings.json to appsettings.Production.json successfully copied"
    else
        # ups.... 
       echo "Error copying backup of appsettings.Production.json"
       exit 1
    fi
fi
################################


  
#  Daemonizing Hideez Enterprise Server 
cp $DESTINATION/HES.Deploy/HES.service   /lib/systemd/system/HES.service

systemctl enable HES.service
systemctl restart HES.service

################################
#Configuring the Nginx Reverse Proxy

#create certs
if [ ! -d /etc/nginx/certs ]; then
    mkdir /etc/nginx/certs
fi
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/hes.key -out /etc/nginx/certs/hes.crt  -subj "/CN=$DOMAIN_NAME"

#Configuration for the Nginx Reverse Proxy

if [[ $DIST == "CentOS Linux" ]]  && [[ $SUB_REV  == "7" ]]; then
	cp $DESTINATION/HES.Deploy/CentOS7/nginx.conf   /etc/nginx/nginx.conf
elif [[ $DIST == "CentOS Linux" ]]  && [[ $SUB_REV  == "8" ]]; then
	cp $DESTINATION/HES.Deploy/CentOS8/nginx.conf   /etc/nginx/nginx.conf
elif [[ $DIST == "Ubuntu" ]]  && [[ $REV  == "18.04" ]]; then
	cp $DESTINATION/HES.Deploy/Ubuntu18/nginx.conf   /etc/nginx/nginx.conf
elif [[ $DIST == "Ubuntu" ]]  && [[ $REV  == "20.04" ]]; then	
	cp $DESTINATION/HES.Deploy/Ubuntu20/nginx.conf   /etc/nginx/nginx.conf
fi

if [[ $DIST == "Ubuntu" ]] 
    then rm /etc/nginx/sites-enabled/default
fi


#Restarting the Nginx Reverse Proxy and check its status
systemctl restart nginx
#sudo systemctl status nginx
################################


#save setting to file
FILE_SETTING=$HOME/$DOMAIN_NAME-setting.txt
##   

#echo DOMAIN_NAME = $DOMAIN_NAME
#echo FILE_SETTING = $FILE_SETTING
##   
BACKUP_SETTING=$HOME/$DOMAIN_NAME-setting$(date +%Y-%m-%d-%H-%M-%S).txt
if [ -f $FILE_SETTING ]; then
    mv $FILE_SETTING $BACKUP_SETTING
fi

cat > $FILE_SETTING << EOF
DOMAIN_NAME = $DOMAIN_NAME
HTTP_PORT = $HTTP_PORT
HTTPS_PORT = $HTTPS_PORT
DATABASE_NAME = $DATABASE_NAME
DATABASE_USER = $DATABASE_USER
USER_PASSWORD = $USER_PASSWORD
SMTP_HOST = $SMTP_HOST
SMTP_PORT = $SMTP_PORT
SMTP_USER_NAME = $SMTP_USER_NAME
SMTP_PASSWORD = $SMTP_PASSWORD
VERSION_HES = $VERSION_HES
EOF

cat $FILE_SETTING


echo "  for testing status HES server:"
echo "sudo systemctl status HES.service"
echo "In your home directory, has been created file $DOMAIN_NAME-setting.txt with your settings."
echo "For your safety, after making sure everything works, it is advised to save your settings somewhere and delete this file"

