
## 1. Install .NET Core, MySQL and nginx

```bash
sudo bash installCommon.sh
```
## 2. Setting a permanent MySQL root password and security settings
 
```bash
sudo mysql_secure_installation
```
**Note**:  during the installation process, depending on the Linux distribution, you may need to enter some additional data (Mysql root password, confirmation, etc.)
## 3. Reboot system
```bash
sudo reboot now
```

## 4. Install HES
```bash
sudo bash installHES.sh
```
**Note**: be prepared to enter the MySQL root password, user password, information about your mail server


