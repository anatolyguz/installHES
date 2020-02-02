send script to remote in local comp:

scp <local_path_to_script>/freshinstall.sh @:

then connect to remote ssh @

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
