## 1. Download scrips to local folder

```bash
mkdir ~/installHES
cd ~/installHES
curl https://raw.githubusercontent.com/anatolyguz/installHES/master/scripts/detectOS.sh > detectOS.sh
curl https://raw.githubusercontent.com/anatolyguz/installHES/master/scripts/installCommon.sh > installCommon.sh
curl  https://raw.githubusercontent.com/anatolyguz/installHES/master/scripts/installHES.sh > installHES.sh
```


## 2. Install .NET Core, MySQL and nginx

```bash
sudo bash installCommon.sh
```
## 3. Setting a permanent MySQL root password and security settings
 
```bash
sudo mysql_secure_installation
```
**Note**:  during the installation process, depending on the Linux distribution, you may need to enter some additional data (Mysql root password, confirmation, etc.)
## 4. Reboot system
```bash
sudo reboot now
```

## 5. Install HES
```bash
cd ~/installHES
sudo bash installHES.sh
```
**Note**: be prepared to enter the MySQL root password, user password, information about your mail server


