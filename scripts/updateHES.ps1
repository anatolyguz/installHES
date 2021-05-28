
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


Set-Location $DESTINATION

git pull 
git branch -r

git fetch
git checkout $BRANCH
#git pull 
git pull $BRANCH

git checkout $TAG


#if ($?) 
#{
# echo "switch to branch $BRANCH"
#} 
#else 
#{
#    # ups.... 
#  echo 'error switchung to branch $BRANCH'
#  exit 1
#}


#for testing  version only
get-content HES.Web/HES.Web.csproj | select-string "<Version>"

# stoping  service
Set-Location $env:windir\System32\inetsrv

.\appcmd.exe  stop site /site.name:$HESSERVICE

#.\appcmd.exe  stop site /site.name:$HESSERVICE
#if ($?)
#{
#    echo "Site stopped"
#}
#
#else
#{
#   echo 'Site not stopped!'
#   exit 1
#}

#iisreset

#New-Item -Path $HES_DIR -Name "app_offline.htm" -ItemType "file"

iisreset /stop

$BACKUP_HES_DIR = $HES_DIR + "-" + (Get-Date -Format "yyyy-mm-dd-HH-mm-ss") + ".Old"


#echo "BACKUP_HES_DIR = $BACKUP_HES_DIR"

Rename-Item  -force -Path $HES_DIR -NewName $BACKUP_HES_DIR

if ($?)
{
    echo "Create of backup HES dir"
}
else
{
   echo 'Error Create of backup HES dir!'
   exit 1
}

#Remove-Item -Path $BACKUP_HES_DIR\app_offline.htm


$MYSQL_HOME='C:\Program Files\MySQL\MySQL Server 8.0'
Set-Location "$MYSQL_HOME\bin"

#& .\mysqldump.exe -u root -p$MYSQL_ROOT_PASSWORD  db > C:\db.sql 

#& .\mysqldump.exe -u user -ppassword  db > C:\db.sql 

#


# create temp file with password fo root

$tmpfie = New-TemporaryFile
#echo $tmpfie.FullName

Add-Content -path $tmpfie.FullName @"
[client]
password = "$MYSQL_ROOT_PASSWORD"

[mysqldump]
user = root
host = localhost
"@

.\mysqldump.exe  --defaults-extra-file=$tmpfie -u root --result-file=$BACKUP_HES_DIR\$DATABASE_NAME.sql  "$DATABASE_NAME"

#  altenative is  (but error code <> 0)
#  .\mysqldump.exe -u root -p"$MYSQL_ROOT_PASSWORD"  --result-file="$BACKUP_HES_DIR"\"$DATABASE_NAME".sql  --databases "$DATABASE_NAME"

if ($?)
{
    echo "create dump of database is correct"
}

else
{
   echo 'Failure create dump of database!'
   exit 1
}

Remove-Item $tmpfie.FullName


#Building application
Set-Location $DESTINATION/HES.Web/
dotnet publish -c $VERSION -v d -o $HES_DIR --runtime win-x64 HES.Web.csproj

if ($?)
{
    echo "the application was compiled successfully"
}

else
{
    # ups.... 
    echo "application compilation error"
    exit 1
}


# copying an old json file 
$JSON=$HES_DIR+"\appsettings.Production.json"
$BACKUP_JSON=$BACKUP_HES_DIR+"\appsettings.Production.json"
Copy-Item -Path $BACKUP_JSON -Destination $JSON


# startiing  service

iisreset /start
Set-Location $env:windir\System32\inetsrv 
.\appcmd.exe  start site /site.name:$HESSERVICE

#that's all ..
