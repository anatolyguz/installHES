
Param (

    [Parameter(Mandatory=$true)]  $MYSQL_ROOT_PASSWORD,
    $REPO="https://github.com/HideezGroup/HES",
    $DESTINATION="C:\Hideez\src",
    $BRANCH="master",
    $TAG="HEAD",
    $VERSION="release",
    $HES_DIR="C:\Hideez\HES",
    $HESSERVICE="HES",
    $DATABASE_NAME="db"
)


write-host "MYSQL_ROOT_PASSWORD = $MYSQL_ROOT_PASSWORD" 
write-host "REPO = $REPO" 
write-host "DESTINATION = $DESTINATION"
write-host "BRANCH = $BRANCH"
write-host "TAG = $TAG"
write-host "VERSION = $VERSION"
write-host "HES_DIR = $HES_DIR"
write-host "HESSERVICE = $HESSERVICE"
write-host "DATABASE_NAME = $DATABASE_NAME"


cd $DESTINATION

git fetch
git checkout $BRANCH


git pull 
#git pull $BRANCH

git checkout $TAG


#for testing  version only
get-content HES.Web/HES.Web.csproj | select-string "<Version>"


# stoping  service
cd $env:windir\System32\inetsrv

# appcmd stop site /site.name:$HESSERVICE

#$env:windir\System32\inetsrv\appcmd.exe stop site /site.name:$HESSERVICE

.\appcmd.exe  stop site /site.name:$HESSERVICE

$BACKUP_HES_DIR = $HES_DIR + (Get-Date -Format "yyyy-mm-dd-HH-mm-ss") + ".Old"


write-host "BACKUP_HES_DIR = $BACKUP_HES_DIR"

Rename-Item -Path $HES_DIR -NewName $BACKUP_HES_DIR


$MYSQL_HOME='C:\Program Files\MySQL\MySQL Server 8.0'
Set-Location "$MYSQL_HOME\bin"

#& .\mysqldump.exe -u root -p$MYSQL_ROOT_PASSWORD  db > C:\db.sql 

#& .\mysqldump.exe -u user -ppassword  db > C:\db.sql 


$temfile = New-TemporaryFile

Add-Content -path $temfile @"
[mysqldump]
user=root
password=$MYSQL_ROOT_PASSWORD
"@



#.\mysqldump.exe --defaults-file=$temfile.FullName --result-file=C:\db.sql  --databases $DATABASE_NAME


write-host "temfile.FullName = $temfile.FullName"


#Remove-Item $temfile.FullName

$ppp='mypassword'


cmd /c .\mysql.exe -N -s -r -u root -p$ppp -e 'show databases'
