#usage
#bash install_virtual_site.sh




###SETTING BLOCK

DESTINATION="/opt/src"
BRANCH="master"

#######################################
#If you want the script to ask no questions, un comment and fill in these variables
# (USER_PASSWORD must comply with mysql policy!)

#DOMAIN_NAME=""
#HTTP_PORT=""
#HTTPS_PORT=""
#DATABASE_NAME=""
#DATABASE_USER=""
#USER_PASSWORD=""
#SMTP_HOST=""
#SMTP_PORT=""
#SMTP_USER_NAME=""
#SMTP_PASSWORD=""
#######################################




#domain name
if [ -z "$DOMAIN_NAME" ] 
then
    read -p "Enter domain name (or leave it blank for use hideez.example.com): " item
    DOMAIN_NAME="${item:-hideez.example.com}"
fi

echo DOMAIN_NAME = $DOMAIN_NAME

if [ -z "$HTTP_PORT" ]
then
    read -p "Enter a numer of http port for site (or leave it blank for use port 5000): " item
    HTTP_PORT=${item:-5000}

fi
echo HTTP_PORT = $HTTP_PORT

if [ -z "$HTTPS_PORT" ]
then
    read -p "Enter a numer of https port for site (or leave it blank for use port 5001): " item
    HTTPS_PORT=${item:-5001}
fi
echo HTTPS_PORT = $HTTPS_PORT

if [ -z "MYSQL_ROOT_PASSWORD" ]
then
    read -p "Enter mysql root password: " MYSQL_ROOT_PASSWORD
fi

#database name
if [ -z "$DATABASE_NAME" ]
then
    read -p "Enter mysql database name (or leave it blank for use defaultname base (db)): " item
    DATABASE_NAME=${item:-db}
fi    
echo DATABASE_NAME = $DATABASE_NAME

#user account
if [ -z "$DATABASE_USER" ]
then
    echo "Enter the name of the new user, the owner of our database"
    read -p "(or leave it blank for create default account (user)): " item
    DATABASE_USER=${item:-user}
fi
echo DATABASE_USER = $DATABASE_USER

if [ -z "$USER_PASSWORD" ] 
then
    USER_PASSWORD=""
    # need strong passsword
    # repeats until you meet the requirements
    #until [[ ${#USER_PASSWORD} -ge 9 ]] && [[ "$USER_PASSWORD" =~ [A-Z] ]] && [[ "$USER_PASSWORD" =~ [a-z] ]] &&  [[ "$USER_PASSWORD" =~ [0-9] ]] &&  [[ "$USER_PASSWORD" =~ [@#$%\&*+=-] ]] 
    until [[ ${#USER_PASSWORD} -ge 9 ]] && [[ "$USER_PASSWORD" =~ [A-Z] ]] && [[ "$USER_PASSWORD" =~ [a-z] ]] &&  [[ "$USER_PASSWORD" =~ [0-9] ]] 
    do
        read -p "Enter strong password for user $DATABASE_USER (at least 8 (upper and lowercase letters, numbers, and special characters)): " USER_PASSWORD
    done
fi

echo USER_PASSWORD = $USER_PASSWORD

if [ -z "$SMTP_HOST" ]
then
    read -p "Enter SMTP host: " SMTP_HOST
fi
echo echo SMTP_HOST = $SMTP_HOST


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

if [ -z "$MYSQL_ROOT_PASSWORD" ] 
then
    read -p "Enter MySQL root password (You installed it earlier): " MYSQL_ROOT_PASSWORD
fi
echo MYSQL_ROOT_PASSWORD = $MYSQL_ROOT_PASSWORD


SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

########################### end settings zone



#create backup src
if [ -d $DESTINATION ]; then
    mv $DESTINATION $DESTINATION-$(date +%Y-%m-%d-%H-%M-%S)
fi

#Cloning the HES GitHub repository

git clone https://github.com/HideezGroup/HES -b $BRANCH $DESTINATION

if [ $? -eq 0 ]; then
  echo "repository successfully cloned"
else
  # ups....
  echo error
  exit 1
fi


#######################################################

#Creating MySQL User
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$DATABASE_USER'@'127.0.0.1' IDENTIFIED BY '$USER_PASSWORD';"

#if [ $USE_RANDOM_PASSWORDS -eq 1 ]
#then
#     #random password
#    here is Poblem in bash with symbols @, / < , etc. 
#    USER_PASSWORD=$( mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$DATABASE_USER'@'127.0.0.1' IDENTIFIED BY RANDOM PASSWORD ;"  | awk '$1 == "'$DATABASE_USER'" {print $3}')
#else 
#    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$DATABASE_USER'@'127.0.0.1' IDENTIFIED BY '$USER_PASSWORD';"
#fi

#Creating MySQL Database for the Hideez Enterprise Server

DATABASE_NAME_FOR_MYSQL=$DATABASE_NAME 
#if name of database base contains a character "-"
# then the name of the base must be enclosed in reverse apostrophe
if [[ "$DATABASE_NAME" == *"-"* ]]; then
  DATABASE_NAME_FOR_MYSQL="\`$DATABASE_NAME\`"
fi

mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS $DATABASE_NAME_FOR_MYSQL;
GRANT ALL ON $DATABASE_NAME_FOR_MYSQL.* TO '$DATABASE_USER'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF

################################
 
#Building the Hideez Enterprise Server from the sources
 
HES_DIR=/opt/HES/$DOMAIN_NAME

if [ -d $HES_DIR ]; then
    mv $HES_DIR $HES_DIR-$(date +%Y-%m-%d-%H-%M-%S)
fi

cd $DESTINATION/HES.Web/
mkdir $HES_DIR
dotnet publish -c release -v d -o $HES_DIR --framework netcoreapp3.1 --runtime linux-x64 HES.Web.csproj
cp $DESTINATION/HES.Web/Crypto_linux.dll $HES_DIR/Crypto.dll

# change setting in  appsettings.json
# Default string is
# "DefaultConnection": "server=127.0.0.1;port=3306;database=db;uid=user;pwd=password"

sed -i 's/database=db/database='$DATABASE_NAME'/' $HES_DIR/appsettings.json
sed -i 's/uid=user/uid='$DATABASE_USER'/' $HES_DIR/appsettings.json
sed -i 's/pwd=password/pwd='$USER_PASSWORD'/' $HES_DIR/appsettings.json


#smtp setting
# Default strings is
# "EmailSender": {
#    "Host": "smtp.example.com",
#    "Port": 123,
#    "EnableSSL": true,
#    "UserName": "user@example.com",
#    "Password": "password"
#  },

sed -i 's/"Host": "smtp.example.com"/"Host": "'$SMTP_HOST'"/' $HES_DIR/appsettings.json
sed -i 's/"Port": 123/"Port": '$SMTP_PORT'/' $HES_DIR/appsettings.json
sed -i 's/"UserName": "user@example.com"/"UserName": "'$SMTP_USER_NAME'"/' $HES_DIR/appsettings.json
sed -i 's/"Password": "password"/"Password": "'$SMTP_PASSWORD'"/' $HES_DIR/appsettings.json


# adding port setting to appsettings.json 
# (after the line with phrathe "AllowedHosts" )
KESTRELVALUE=',\
\
\"Kestrel\": {\
  \"Endpoints\": {\
    \"Http\": {\
      \"Url\":  \"http://localhost:'$HTTP_PORT'\"\
      },\
    \"Https\": {\
      \"Url\":  \"https://localhost:'$HTTPS_PORT'\"\
      }\
    }\
 }\
'

sed -i '/AllowedHosts/a\'"${KESTRELVALUE}" $HES_DIR/appsettings.json



################################
  
#  Daemonizing Hideez Enterprise Server 

cat > /lib/systemd/system/HES-$DOMAIN_NAME.service << EOF
[Unit]
  Description=$DOMAIN_NAME Hideez Enterprise Service
[Service]
  User=root
  Group=root
  WorkingDirectory=$HES_DIR
  # ExecStart=$HES_DIR/HES.Web --server.urls "http://localhost:$HTTP_PORT;https://localhost:$HTTPS_PORT"
  ExecStart=$HES_DIR/HES.Web --server.urls
  Restart=on-failure
  ExecReload=/bin/kill -HUP $MAINPID
  KillMode=process
  # SyslogIdentifier=dotnet-sample-service
  # PrivateTmp=true"
[Install]
  WantedBy=multi-user.target
EOF

systemctl enable HES-$DOMAIN_NAME.service
systemctl restart HES-$DOMAIN_NAME.service

################################
#Configuring the Nginx Reverse Proxy

#create certs
if [ ! -d /etc/nginx/certs ]; then
    mkdir /etc/nginx/certs
fi
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/$DOMAIN_NAME.key -out /etc/nginx/certs/$DOMAIN_NAME.crt  -subj "/C=''/ST=''/L=''/O='' Security/OU=''/CN=''"

#Configuration for the Nginx Reverse Proxy
cat > /etc/nginx/conf.d/$DOMAIN_NAME.conf << EOF
server {
        listen       80;
        #or if it is one single server
        #listen       80 default_server; 
        listen       [::]:80;
        #or if it is one single server
        #listen       [::]:80 default_server;
        server_name  $DOMAIN_NAME;
        location / {
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            # Enable proxy websockets for the Hideez Client to work
            proxy_http_version 1.1;
            proxy_buffering off;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection \$http_connection;
            proxy_pass https://localhost:$HTTPS_PORT;
        }
}
server {
        listen       443 ssl http2;
        #or if it is one single server
        #listen       443 ssl http2 default_server; 
        listen       [::]:443 ssl http2;
        #or if it is one single server
        #listen       [::]:443 ssl http2 default_server;
        
        server_name  $DOMAIN_NAME;
        ssl_certificate "certs/$DOMAIN_NAME.crt";
        ssl_certificate_key "certs/$DOMAIN_NAME.key";
        location / {
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            # Enable proxy websockets for the hideez Client to work
            proxy_http_version 1.1;
            proxy_buffering off;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection \$http_connection;
            proxy_pass https://localhost:$HTTPS_PORT;
        }
}
EOF


#Restarting the Nginx Reverse Proxy and check its status
systemctl restart nginx
sudo systemctl status nginx

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
EOF

cat $FILE_SETTING


echo "systemctl status HES-$DOMAIN_NAME.service"
echo "In your home directory, has been created file $DOMAIN_NAME-setting.txt with your settings."
echo "For your safety, after making sure everything works, it is advised to save your settings somewhere and delete this file"


