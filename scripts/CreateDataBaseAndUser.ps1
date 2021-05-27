Param (

    [Parameter(Mandatory=$true)]  $MYSQL_ROOT_PASSWORD,
    [Parameter(Mandatory=$true)]  $MYSQL_USER_PASSWORD
)


$MYSQL_HOME='C:\Program Files\MySQL\MySQL Server 8.0'

$PASSWORD_OF_USER = "hiuser"

Set-Location "$MYSQL_HOME\bin"

$SCRIPT = @"
CREATE DATABASE db;
CREATE USER 'user'@'127.0.0.1' IDENTIFIED BY '$MYSQL_USER_PASSWORD';
GRANT ALL ON db.* TO 'user'@'127.0.0.1';
FLUSH PRIVILEGES;
"@

.\mysql.exe -u root -p"$MYSQL_ROOT_PASSWORD" -e $SCRIPT

