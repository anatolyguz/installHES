#/bin/bash


if grep -q  CentOS  /etc/os-release
	then yum install makepasswd -y
elif grep -q  Ubuntu  /etc/os-release
	then apt install makepasswd -y
fi

######################################
#If you want the script to ask no questions, uncomment and fill in these variables
# (USER_PASSWORD must comply with mysql policy!)

#DOMAIN_NAME=""
#HTTP_PORT=""
#HTTPS_PORT=""
#DATABASE_NAME=""
#DATABASE_USER=""
#USER_PASSWORD=""
#SQLROOT_PASSWORD=""
#SMTP_HOST=""
#SMTP_PORT=""
#SMTP_USER_NAME=""
#SMTP_PASSWORD=""
#######################################

#rm -rf /opt/HES

#domain name
if [ -z "$DOMAIN_NAME" ] 
then
    read -p "Enter domain name (or leave it blank for use hideez.example.com): " item
    DOMAIN_NAME="${item:-hideez.example.com}"
fi

echo DOMAIN_NAME = $DOMAIN_NAME


# #database name
# if [ -z "$DATABASE_NAME" ]
# then
#     read -p "Enter mysql database name (or leave it blank for use defaultname base (db)): " item
#     DATABASE_NAME=${item:-db}
# fi    
# echo DATABASE_NAME = $DATABASE_NAME


# #user account
# if [ -z "$DATABASE_USER" ]
# then
#     echo "Enter the name of the new user, the owner of our database"
#     read -p "(or leave it blank for create default account (user)): " item
#     DATABASE_USER=${item:-user}
# fi
# echo DATABASE_USER = $DATABASE_USER


# if [ -z "$USER_PASSWORD" ] 
# then
#     USER_PASSWORD=""
#     # need strong passsword
#     # repeats until you meet the requirements
#     #until [[ ${#USER_PASSWORD} -ge 9 ]] && [[ "$USER_PASSWORD" =~ [A-Z] ]] && [[ "$USER_PASSWORD" =~ [a-z] ]] &&  [[ "$USER_PASSWORD" =~ [0-9] ]] &&  [[ "$USER_PASSWORD" =~ [@#$%\&*+=-] ]] 
#     until [[ ${#USER_PASSWORD} -ge 9 ]] && [[ "$USER_PASSWORD" =~ [A-Z] ]] && [[ "$USER_PASSWORD" =~ [a-z] ]] &&  [[ "$USER_PASSWORD" =~ [0-9] ]] 
#     do
#         read -p "Enter strong password for user $DATABASE_USER (at least 8 (upper and lowercase letters, numbers, and special characters)): " USER_PASSWORD
#     done
# fi

#USER_PASSWORD=$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev)
USER_PASSWORD=$(makepasswd  --chars=12)

echo USER_PASSWORD = $USER_PASSWORD


#SQLROOT_PASSWORD=""
# if [ -z "$SQLROOT_PASSWORD" ]
# then
#     SQLROOT_PASSWORD=""
#     # need strong passsword
#     # repeats until you meet the requirements
#     #until [[ ${#USER_PASSWORD} -ge 9 ]] && [[ "$USER_PASSWORD" =~ [A-Z] ]] && [[ "$USER_PASSWORD" =~ [a-z] ]] &&  [[ "$USER_PASSWORD" =~ [0-9] ]] &&  [[ "$USER_PASSWORD" =~ [@#$%\&*+=-] ]] 
#     until [[ ${#SQLROOT_PASSWORD} -ge 9 ]] && [[ "$SQLROOT_PASSWORD" =~ [A-Z] ]] && [[ "$SQLROOT_PASSWORD" =~ [a-z] ]] &&  [[ "$SQLROOT_PASSWORD" =~ [0-9] ]] 
#     do
#         read -p "Enter strong password for MySQL root  (at least 8 (upper and lowercase letters, numbers, and special characters)): " SQLROOT_PASSWORD
#     done
# fi
#SQLROOT_PASSWORD=$(dd if=/dev/urandom bs=1 count=12 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev)
SQLROOT_PASSWORD=$(makepasswd  --chars=12)
echo SQLROOT_PASSWORD = $SQLROOT_PASSWORD



mkdir -p /opt/HES
cp -r /opt/src/HES/HES.Docker/* /opt/HES
mkdir -p /opt/HES/$DOMAIN_NAME
mkdir -p /opt/HES/$DOMAIN_NAME/logs
cp /opt/src/HES/HES.Web/appsettings.json /opt/HES/$DOMAIN_NAME



APPSETTINGS="/opt/HES/$DOMAIN_NAME/appsettings.json"

sed -i 's/server=127.0.0.1/server=hes-db/' $APPSETTINGS
#sed -i 's/database=db/database='$DATABASE_NAME'/' $APPSETTINGS
#sed -i 's/uid=user/uid='$DATABASE_USER'/' $APPSETTINGS
sed -i 's/pwd=password/pwd='$USER_PASSWORD'/' $APPSETTINGS

DOCKERCOMPOSE="/opt/HES/docker-compose.yml"

#sed -i 's/MYSQL_DATABASE: db/MYSQL_DATABASE: '$DATABASE_NAME'/' $DOCKERCOMPOSE
#sed -i 's/MYSQL_USER: user/MYSQL_USER: '$DATABASE_USER'/' $DOCKERCOMPOSE
sed -i 's/MYSQL_PASSWORD: password/MYSQL_PASSWORD: '$USER_PASSWORD'/' $DOCKERCOMPOSE
sed -i 's/MYSQL_ROOT_PASSWORD: password/MYSQL_ROOT_PASSWORD: '$SQLROOT_PASSWORD'/' $DOCKERCOMPOSE

sed -i 's/<Name_Of_Domain>/'$DOMAIN_NAME'/' $DOCKERCOMPOSE
	    

NGINX="/opt/HES/nginx/nginx.conf"
sed -i 's/<Name_Of_Domain>/'$DOMAIN_NAME'/' $NGINX


PATH_CERT="/opt/HES/nginx/certs"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $PATH_CERT/$DOMAIN_NAME.key -out $PATH_CERT/$DOMAIN_NAME.crt  -subj "/C=''/ST=''/L=''/O='' Security/OU=''/CN=''"

cd /opt/HES/
docker-compose up -d --build
docker-compose down 
docker-compose up -d
docker-compose ps
