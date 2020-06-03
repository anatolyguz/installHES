# 1. Preparation for connection Linux server to Active Directory

Edit the file /etc/hosts, add (or edit) the line specifying the Fully Qualified Domain Name for this host (change it to your host name and <Domain_Name> to the domain name):
```shell
127.0.1.1       <hostname>.<Domain_Name>  <hostname>
#for hostname hideez and domain examle.com
#127.0.1.1       hideez.example.com  hideez
```

Before you start, you need to check that your active directory server is available by name and address, you can use the nslookup utility

Check that the domain name resolves. Note: under Centos, it may be required to install the bind-utils package:
```shell
sudo yum install bind-utils -y
```

```shell
nslookup <Domain_Name>
```

if we get a "Can't find <Domain Name> No answer" error, we may need to perform some configuration steps

It may also be necessary to add the Fully Qualified Domain Name for the AD server depending on the network settings. 
```shell
<server_ip>       <Server_Name>.<Domain_Name>  <Server_Name>
```
The AD server must be installed as a DNS server for a correct connection to AD. If DHCP is running on your network, as a rule, the administrator has already assigned the correct settings for your server. You can see a list of current DNS in the resolv.conf file:
```shell
cat /etc/resolv.conf
```
The IP of the AD server will appear as a nameserver. 
Otherwise, you can manually assign the nameserver. When using DHCP, you cannot modify resolv.conf directly, so it will be necessary to follow a few simple steps. 
 
## Ubuntu 18.04
Let`s install resolvconf package
```shell
sudo apt update
sudo apt install resolvconf
sudo systemctl enable resolvconf.service
```
You will then need to edit the `/etc/resolvconf/resolv.conf.d/head` file. Add the line:
```shell
nameserver  <server_ip>
```
and start
```shell
sudo systemctl start resolvconf.service
```
## Centos 7
The following lines should be added
```shell
PEERDNS=no
DNS1=<server_ip>
```
to the file `/etc/sysconfig/network-scripts/ifcfg-<name_interface> Here you need to replace <interface> with the name of your network interface and restart NetworkManager
```shell 
sudo systemctl restart  NetworkManager
```
Check your resolv.conf again to make sure everything is correct 
```shell
cat /etc/resolv.conf
```
# 2. Install the necessary packages
### Ubuntu 18.04
```shell
sudo apt install realmd samba-common-bin samba-libs sssd-tools krb5-user adcli
```

### Centos 7
```shell
sudo yum install sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation openldap-clients policycoreutils-python -y
```
# 3. Check that our domain is visible on the network

You must confirm the domain during the installation of kerberos, and specify the server name.

```shell
realm discover <Domain_Name>
```

# 3. Join the machine to a domain

```shell
sudo realm --verbose join <Domain_Name> -U <YourDomainAdmin> --install=/
```
If there is no error, everything went fine. You can go to the domain controller and check if our linux server appears in the domain.
If the Active Directory server uses self-signed certificates, you need to edit the `ldap.conf` file. In ubuntu it is stored in `/etc/ldap/ldap.conf`, in Centos - `/etc/openldap/ldap.conf`.
You should specify (add at the end of the file) this parameter: 
```shell
TLS_REQCERT never
```

# 4. Installation check
For example, to get all users (you have to enter a password):
```shell
ldapsearch -x -H "ldaps://<Domain_Name>" -D "<YourDomainAdmin>@<Domain_Name>" -W  -b "dc=<dc>,dc=<dc>, ..." "objectCategory=person" name
```

In case we have the hideez.example.com domain and an administrator named "administrator", the command would look like this:
```shell
ldapsearch -x -H "ldaps://hideez.example.com" -W -D "administrator@hideez.example.com" -b "dc=hideez,dc=example,dc=com"  "objectCategory=person" name
```
In case of an error, you can add the -d1 key and read the description of the error.
