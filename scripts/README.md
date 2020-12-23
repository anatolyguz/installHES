
## 1. Install .NET Core, MySQL and nginx:

```bash
sudo  chmode +x install_common.sh
sudo ./install_common.sh
```
## 2. Setting a permanent MySQL root password and security settings
```bash
sudo mysql_secure_installation
```
## 3. Reboot system
```bash
sudo reboot now
```

## 4. Install HES
```bash
sudo  chmode +x installHES.sh
sudo ./installHES.sh
```

