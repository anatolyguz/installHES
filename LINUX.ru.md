# Разворачивание на Linux

## Важное замечание
Установка сервера состоит из двух частей:
Первая часть описывает общие требования. 
Во второй части описана установка уже для конкретного сайта, виртуальных сайтов может быть несколько, поэтому этот шаг можно повторять несколько раз

## Требования к системе

  * Git
  * Nginx
  * .NET Core (.NET Core SDK версия 2.2).
  * MySQL Server (версия 8.0+).
    
  
примечание: Если установка производится на уже работающей системе, на которой уже возможно установлен и настроен mysql, nginx и прочее (или при повторной установке), следует это учитывать, иначе есть риск потерять важные данные, которые хранятся на этом компьтере).
Здесь (и далее) предполагается, что система "чистая" и накаких дополнительных программ не установлено.

Все шаги производились на свежеустановленном [CentOS 7](https://www.centos.org/about/))

# 1. Подготовка (Выполняется один раз)
 
  
## 1.1 Обновление системы
  
  (если еще не обновлена)

```shell
  $ sudo yum update -y
```

## 1.2 Установка git

```shell
  $ sudo yum install git -y 
 ```

## 1.3 Загрука репозитория HES из GitHub

```shell
  $ sudo git clone https://github.com/HideezGroup/HES /opt/src 
  cd src/HES.Web/
```

## 1.4 Отключение SELinux

```shell
  $ sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
  $ sudo setenforce 0
```

## 1.5 Добавление репозитория пакетов Microsoft и установка .NET Core:

```shell
  $ sudo rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm
  $ sudo yum install dotnet-sdk-2.2 -y
```

Если установка прошла удачно, то вывод команды dotnet будет выглядеть примерно так:

```shell
  $ dotnet
 
Usage: dotnet [options]
Usage: dotnet [path-to-application]

Options:
  -h|--help         Display help.
  --info            Display .NET Core information.
  --list-sdks       Display the installed SDKs.
  --list-runtimes   Display the installed runtimes.

path-to-application:
  The path to an application .dll file to execute.
 
  ```

## 1.6 Добавление репозитория пакетов MySQL и установка MySQL:

```shell
  $ sudo rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
  $ sudo yum install mysql-server -y
  ```


До первого запуска  mysql server, необходимо установить lower_case_table_names=1 в файл  /etc/my.cnf:

```shell
  $ sudo echo "lower_case_table_names=1" >> /etc/my.cnf
  ```

Включение и запуск службы MySQL

```shell
  $ sudo systemctl restart mysqld.service
  $ sudo systemctl enable mysqld.service
```





После установки mysql, если все прошло удачно, можно проверить версию программы 

```shell
  $ mysql -V
mysql  Ver 8.0.19 for Linux on x86_64 (MySQL Community Server - GPL)
```

При установке mysql для пользовтеля root@localhost был сгенерирован ВРЕМЕННЫЙ пароль, он может быть найден при помощи команды 

```shell
  $ sudo grep "A temporary password" /var/log/mysqld.log
  2020-01-25T08:11:05.615222Z 5 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: qx7lxa<dqknE
```
или (только пароль)

```shell
  $ sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $13}'
qx7lxa<dqknE
```

следует ввести этот пароль при выполении следующих шагов.

Установка постоянного реального пароля root и настройка безопасности mysql.

При выполнении следющей команды, слудет сменить временный пароль (сначала ввести временый пароль, затем дважды установить новый)
Конечно, mysql ожидает, что Ваш новый пароль должен состоять, как минимум из 8 символов, содержать большие и маленькие буквы, числа и специальные символы (не забудьте установленный пароль, он пригодится далее). После удачной смены пароля, на последующие вопросы рекомендуется ответить "Y":

```shell
  $ sudo mysql_secure_installation
```

```shell
  Enter password for user root:

  The existing password for the user account root has expired. Please set a new password.

  New password:
  Re-enter new password:

  Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) : Y
  
  Remove anonymous users? (Press y|Y for Yes, any other key for No) : Y
  
  Disallow root login remotely? (Press y|Y for Yes, any other key for No) : Y

  Remove test database and access to it? (Press y|Y for Yes, any other key for No) : Y

  Reload privilege tables now? (Press y|Y for Yes, any other key for No) : Y
```

Для проверки, что все прошло удачно, можно выполнить

```shell
  $ mysql -h localhost -u root -p
```
После ввода пароля, откроется консоль mysql c с приглашением для выполнения команд:
```shell
  Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 13
Server version: 8.0.19 MySQL Community Server - GPL

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
  
```
Выход из консол mySql выполняется коммандой 

```
mysql> QUIT;
  
```
 
## 1.7 Установка репозитория EPEL и Nginx
 
```shell
  $ sudo yum install epel-release -y
  $ sudo yum install nginx -y
  $ sudo systemctl enable nginx
  $ systemctl restart nginx
```  
  Проверка, что сервис nginx установлен и запущен:
```shell
  $ sudo systemctl status nginx
  
  ```  
  Вывод будет примерно таким:
 
```shell
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2020-01-25 08:22:56 UTC; 8min ago
  Process: 1702 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 1700 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 1699 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 1704 (nginx)
   CGroup: /system.slice/nginx.service
           ├─1704 nginx: master process /usr/sbin/nginx
           └─1705 nginx: worker process
 ```

После выполения этих шагов в компьютер должен уже быть доступным в сети и отвечать в браузере по ip адресу компьютера или или его доменному имени. (http://<ip_or_domain_name>)



На этом подготовительный этам закончен



# 2 Установка сервера HES (можно повторять для каждого нового виртуального домена)

## 2.1 Создание пользоватея MySQL и базы для  Hideez Enterprise Server

  Запуск консоли MySQL Server 

```shell
  mysql -h localhost -u root -p
```

```sql
  ### CREATE DATABASE
  mysql> CREATE DATABASE <your_db>;

  ### CREATE USER ACCOUNT
  mysql> CREATE USER '<your_user>'@'127.0.0.1' IDENTIFIED BY '<your_secret>';

  ### GRANT PERMISSIONS ON DATABASE
  mysql> GRANT ALL ON <your_db>.* TO '<your_user>'@'127.0.0.1';
 
  ###  RELOAD PRIVILEGES
  mysql> FLUSH PRIVILEGES;
```
Следует запомнить имя базы, имя и пароль пользователя, они понадобятся в дальнейшем

## 2.2 Установка Hideez Enterprise Server из исходного кода

Вместо <Name_Of_Site> укажите свое имя для вашего сервера

```shell
  $ cd /opt/src/HES.Web/
  $ sudo mkdir -p /opt/HES/<Name_Of_Domain>
  $ sudo dotnet publish -c release -v d -o "/opt/HES/<Name_Of_Domain>" --framework netcoreapp2.2 --runtime linux-x64 HES.Web.csproj
  $ sudo cp /opt/src/HES.Web/Crypto_linux.dll /opt/HES/<Name_Of_Domain>/Crypto.dll
```

здесь указан пример для случая, когда наш сайт будет называться  hideez.example.com

```shell
  $ cd /opt/src/HES.Web/
  $ sudo mkdir -p /opt/HES/hideez.example.com
  $ sudo dotnet publish -c release -v d -o "/opt/HES/hideez.example.com" --framework netcoreapp2.2 --runtime linux-x64 HES.Web.csproj
  $ sudo cp /opt/src/HES.Web/Crypto_linux.dll /opt/HES/hideez.example.com/Crypto.dll
```
  * **[Примечание]** Для загрузки пакетов NuGet необходимо подключение к интернету


## 2.3 Конфигурация Hideez Enterprise Server

Необходимо отредактировать файл 
/opt/HES/<Name_Of_Domain>/appsettings.json

Ниже приведен пример, как открыть для редактирования файл конфигурации, для случая, когда домен будет называться hideez.example.com:

```shell
  $ sudo vi /opt/HES/hideez.example.com/appsettings.json
```

```json
  {
  "ConnectionStrings": {
    "DefaultConnection": "server=<mysql_server>;port=<mysql_port>;database=<your_db>;uid=<your_user>;pwd=<your_secret>"
  },

  "EmailSender": {
    "Host": "<email_host>",
    "Port": "<email_port>",
    "EnableSSL": true,
    "UserName": "<your_email_name>",
    "Password": "<your_email_password>"
  },
  
  "DataProtection": {
    "Password": "<protection_password>"
  },

  "Logging": {
    "LogLevel": {
      "Default": "Trace",
      "Microsoft": "Information"
    }
  },

  "AllowedHosts": "*"
}
```

* **<mysql_server>** - MySQL server ip address (example `127.0.0.1`)
* **<mysql_port>** - MySQL server port (example `3306`)
* **<your_db>** - The name of your database on the MySQL server (example `hes`)
* **<your_user>** - MySQL database username (example `admin`)
* **<your_secret>** - Password from database user on MySQL server (example `password`)
* **<email_host>** - Host your email server (example `smtp.example.com`)
* **<email_port>** - Port your email server (example `123`)
* **<your_email_name>** - Your email name (example `user@example.com`)
* **<your_email_password>** - Your email name (example `password`)
* **<protection_password>** - Your password for database encryption (example `password`)

После сохранения файла настроек, можно уже проверить работоспособность  сервера HES:
```shell
  $ cd /opt/HES/<Name_Of_Domain>
  $ sudo ./HES.Web 
```
Вывод должнен выглядеть примерно так:

```shell
Hosting environment: Production
Content root path: /opt/HES/hideez.example.com
Now listening on: http://localhost:5000
Now listening on: https://localhost:5001
Application started. Press Ctrl+C to shut down.

```
это значит что сервер HES успешо сконфигурирован и запущен 

## 2.4 Демонизация Enterprise Server

Важное замечание. По умолчанию .net Core использует в своей работе порты
5000 и 5001. Поэтому, если на сервере будет запущен только одни домен, номера портов можно пропустить. Но если предполагается запус невольких сайтов на одном комьтер, то необзодимио указать разные порты для каждого сайта


Необходимо создать файл  
/lib/systemd/system/HES-<Name_Of_Domain>.service

Ниже, для домена  hideez.example.com,портов 5000 и 5001 показан пример 

```shell
  $ sudo cat > /lib/systemd/system/HES-hideez.example.com.service << EOF
[Unit]
  Description=hideez.example.com Hideez Enterprise Service

[Service]

  User=root
  Group=root

  WorkingDirectory=/opt/HES/hideez.example.com
  ExecStart=/opt/HES/hideez.example.com/HES.Web --server.urls "http://localhost:5000;https://localhost:5001"
  Restart=on-failure
  ExecReload=/bin/kill -HUP $MAINPID
  KillMode=process
  # SyslogIdentifier=dotnet-sample-service
  # PrivateTmp=true

[Install]
  WantedBy=multi-user.target
EOF
```

если на сервер будет только один сервис HES, паратмер
--server.urls "http://localhost:5000;https://localhost:5001"
можно не указывать 



включение в атозагрузку (на примере hideez.example.com) 

```shell
  $ sudo systemctl enable HES-hideez.example.com.service
  $ sudo systemctl restart HES-hideez.example.com.service
```

Проверить, что сервер HES запущен можно командой 

```shell
sudo systemctl status HES-hideez.example.com

```
(конечно, в каждом конкретном случае, вместо "HES-hideez.example.com" , должно быть имя службы, созданное ранее)

Вывод команды должен быть примерно таким:

```shell
● HES-hideez.example.com.service - hideez.example.com Hideez Enterprise Service
   Loaded: loaded (/usr/lib/systemd/system/HES-hideez.example.com.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2020-01-25 10:31:13 UTC; 54min ago
 Main PID: 12976 (HES.Web)
   CGroup: /system.slice/HES-hideez.example.com.service
           └─12976 /opt/HES/hideez.example.com/HES.Web

Jan 25 10:31:13 HESServerTest systemd[1]: Started hideez.example.com Hideez Enterprise Service.
Jan 25 10:31:22 HESServerTest HES.Web[12976]: Hosting environment: Production
Jan 25 10:31:22 HESServerTest HES.Web[12976]: Content root path: /opt/HES/hideez.example.com
Jan 25 10:31:22 HESServerTest HES.Web[12976]: Now listening on: http://localhost:5000
Jan 25 10:31:22 HESServerTest HES.Web[12976]: Now listening on: https://localhost:5001
Jan 25 10:31:22 HESServerTest HES.Web[12976]: Application started. Press Ctrl+C to shut down.

```

## 2.5 Конфигурация обратного прокси
Для доступности сервер аиз локалной сети а также из сети интернета необходимо сконфигурировать обратный прокси

 Создание самоподписвнного SSL серитфиката SSL Certificate для Nginx
 Примечание Для "рельного" сайта следует позаботися о приобретении сертификата в авторизирующего центра.
 Для самоподписанного сертификата браузер будет предупреждать о проблемах с безопасностью сайта.
 
 Ниже показан пример для сайта hideez.example.com
 (при генерации сертификта,  необходимо ответить на несколько простых вопросов)
 
```shell
 $ sudo mkdir /etc/nginx/certs
 $ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/hideez.example.com.key -out /etc/nginx/certs/hideez.example.com.crt
```

 Конфигурация виртуального сайта на обратном прокси Nginx
    
Строки в номерами портов, должны соответствовать настройка, указанным в файле    

/lib/systemd/system/HES-<Name_Of_Domain>.service  

на примере домена hideez.example.com: 
  
Создаем файл  /etc/nginx/conf.d/<Name_Of_Domain>.conf 
 
```shell
  vi /etc/nginx/conf.d/hideez.example.com.conf
```
    
```conf
    server {
        listen       80;
        #or if it is one single server
        #listen       80 default_server;
        listen       [::]:80;
        #or if it is one single server
        #listen       [::]:80 default_server;
        server_name  hideez.example.com;

        location / {
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            # Enable proxy websockets for the Hideez Client to work
            proxy_http_version 1.1;
            proxy_buffering off;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_pass https://localhost:5001;
        }
    }
 
    server {
        listen       443 ssl http2;
        #or if it is one single server
        #listen       443 ssl http2 default_server;
        listen       [::]:443 ssl;
        #or if it is one single server
        #listen       [::]:443 ssl default_server;
        server_name  hideez.example.com;

        ssl_certificate "certs/hideez.example.com.crt";
        ssl_certificate_key "certs/hideez.example.com.key";

        location / {
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            # Enable proxy websockets for the hideez Client to work
            proxy_http_version 1.1;
            proxy_buffering off;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_pass https://localhost:5001;
        }
 }
```

После сохранения файла рекомендуеться проверить настройки nginx:
```shell
  $ sudo nginx -t
```
Вывод должен быть примерно таким:

```shell
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
В противном случае слует внимательно пересмотреть настроки и испрвить ошибки.


Перезапуск Nginx и проверка его статуса

```shell
  $ sudo systemctl restart nginx
  $ sudo systemctl status nginx
  ● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2020-01-25 11:23:46 UTC; 8s ago
  Process: 13093 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 13091 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 13089 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 13095 (nginx)
   CGroup: /system.slice/nginx.service
           ├─13095 nginx: master process /usr/sbin/nginx
           └─13096 nginx: worker process

```

На этом настройка закончена. Сервер должен быть доступен в браузере по адресу
https://<Name_Of_Domain>




## Updating the HES

### 1. Updating the sources from the GitHub repository

```shell
  $ cd /opt/src
  $ sudo git pull
```

### 2. Backing up the Hideez Enterprise Server

```shell
  $ sudo systemctl stop hideez.service
  $ sudo mv /opt/HES /opt/HES.old
```

### 3. Building the Hideez Enterprise Server from the sources

```shell
  $ sudo mkdir /opt/HES
  $ sudo dotnet publish -c release -v d -o "/opt/HES" --framework netcoreapp2.2 --runtime linux-x64 HES.Web.csproj
  $ sudo cp /opt/src/HES.Web/Crypto_linux.dll /opt/HES/Crypto.dll
```
  * **[Note]** Requires internet connectivity to download NuGet packages

### 4. Backuping MySQL Database (optional)

```shell
  $ sudo mkdir /opt/backups && cd /opt/backups
  $ sudo mysqldump -u <your_user> -p <your_secret> <your_db> | gzip -c > <your_db> .sql.gz
```

### 5.  Restoring the configuration file

```shell
  $ sudo cp /opt/HES.old/appsettings.json /opt/HES/appsettings.json
  $ sudo rm -rf /opt/HES.old
```

### 6. Restarting the Hideez Enterprise Server and check its status

```shell
  $ sudo systemctl restart hideez.service
  $ sudo systemctl status hideez.service
  ● hideez.service - Hideez Web service
     Loaded: loaded (/usr/lib/systemd/system/hideez.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2019-11-05 15:34:39 EET; 2 weeks 2 days ago
   Main PID: 10816 (HES.Web)
     CGroup: /system.slice/hideez.service
             └─10816 /opt/HES/HES.Web
```
