send script to remote in local comp:

scp <local_path_to_script>/freshinstall.sh @:

then connect to remote ssh @

exaple from remote to local:

scp root@11.22.33.44:/home/user/file.tar.gz /opt


in remote (with sudo) #bash /freshinstall.sh





disable locale from cliet #LC_TIME="en_US.UTF-8"

#enable network access

```mysql
use mysql;
UPDATE user SET Host='%' WHERE User='root' AND Host='localhost'; FLUSH PRIVILEGES;
```

#Install bash-completion
 ```bash
yum install bash-completion
```

#Install fail2ban
 ```bash
yum install -y epel-release
yum install -y fail2ban
systemctl enable fail2ban

```



