```shell
systemctl stop mysqld.service
mysqld --skip-grant-tables --user=mysql &
mysql -e "FLUSH PRIVILEGES;"
mysql -e "alter user 'root'@'localhost' identified by RANDOM PASSWORD ;"

kill <Pid of mysl process where owner mysql>
```

```shell
#NEW_PASSWORD="aFvf$f55vst3ccb==3#"
#systemctl stop mysqld.services
#echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEW_PASSWORD';" > /opt/init.txt
#mysqld --user=mysql --init-file=init.txt --console
#systemctl stop mysqld.service 
#systemctl start mysqld.service 
```
