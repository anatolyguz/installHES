#/bin/bash
USAGE=`cat << EOF
usage: 
update_HES.sh [otpions]   
 otpions is:
[--r <REPO>]  [--dst <DESTINATION>] [--b  <BRANCH>]  [--t  <TAG>]  [--v  <VERSION>] [ --hesdir  <HES_DIR>] [--hesserver <HES-SERVICE>]
where:
 --r <REPO>                    url HES repo/ Default https://gitub.com/HideezGroup/HES  
 --dst <DESTINATION>           destinations of local HES source directory. Default  /opt/src/HES
 --b  <BRANCH>                 name of Branch. Default master
 --t  <TAG>                    tag of repo. Default current last commit
 --v  <VERSION>                version of build release or debug Default realese
 --hesdir  <HES_DIR>           path to HES bin directory. Default /opt/HES
 --hesservice  <HES-SERVICE>   name of HES-service. Default HES
EOF
`


REPO="https://github.com/HideezGroup/HES"
DESTINATION="/opt/src/HES"
BRANCH="master"
TAG="HEAD"
VERSION="release"
HES_DIR="/opt/HES"
HESSERVICE="HES.service"


while [ -n "$1" ]

do

        if [ -z "$2" ] 
        then
        echo "ERROR! no values specified after "$1" !"
        echo "$USAGE"
        exit 1
        fi
        param="$2"

        case "$1" in

                --r) 
                        REPO=$param
                        shift ;;
                --dst) 
                        DESTINATION=$param
                        shift ;;
                --b) 
                        BRANCH=$param
                        shift ;;
                --t) 
                        TAG=$param
                        shift ;;
                --v)
                        VERSION=$param
                        shift ;;
                --hesdir)
                        HES_DIR=$param
                        shift ;;
                --hesservice)
                        HESSERVICE=$param
                        shift ;;

                --) shift
                break ;;
                *) echo "ERROR! $1 is not an option"
                   echo "$USAGE"
                   exit 1
        esac
        shift
done


echo "REPO = $REPO"
echo "DESTINATION = $DESTINATION"
echo "BRANCH = $BRANCH"
echo "TAG = $TAG"
echo "VERSION = $VERSION"
echo "HES_DIR = $HES_DIR"
echo "HESSERVICE = $HESSERVICE"


#################################################

#parsing json for create dump of database

JSON_FILE=$HES_DIR/appsettings.Production.json

# name of database between "database="  and  ";uid"
DATABASE_NAME=$(sed -n 's:.*database=\(.*\);uid.*:\1:pgI' $JSON_FILE)
# name of user between "uid="  and  ";"
DATABASE_USER=$(sed -n 's:.*uid=\(.*\);.*:\1:pgI' $JSON_FILE)
# password  of user between "pwd="  and  '"'
DATABASE_PASSWORD=$(sed -n 's:.*pwd=\(.*\)".*:\1:pgI' $JSON_FILE)

echo "DATABASE_NAME = $DATABASE_NAME"
echo "DATABASE_USER = $DATABASE_USER"
echo "DATABASE_PASSWORD = $DATABASE_PASSWORD"

#   alternative with grep:
#  DATABASE_NAME=$(grep -o -P '(?<=database=).*(?=;uid)' $JSON_FILE)

#################################################

cd $DESTINATION

git fetch
git checkout $BRANCH

if [ $? -eq 0 ]; then
  echo "switch to branch $BRANCH"
else
  # ups.... 
  echo "error switchung to branch $BRANCH"
  exit 1
fi

git pull $BRANCH

git checkout $TAG
if [ $? -eq 0 ]; then
  echo "switch to tag $TAG"
else
  # ups.... 
  echo "error switchung to tag $TAG"
  exit 1
fi


git pull

#for testing  version only
cat HES.Web/HES.Web.csproj | grep "<Versio\n>"

#################################################


## real upgrade:

# stoping  service
systemctl stop $HESSERVICE
if [ $? -eq 0 ]; then
        echo "HES service is stopped"
else
    # ups.... 
    echo "HES service stop error"
    exit 1
fi

# Create backup HES directory
BACKUP_HES_DIR=$HES_DIR-$(date +%Y-%m-%d-%H-%M-%S).Old

if [ -d $HES_DIR ]; then
        mv $HES_DIR $BACKUP_HES_DIR
fi

if [ $? -eq 0 ]; then
        echo "move to backup HES folder was compiled successfully"
else
    # ups.... 
    echo "move HES foler to backup error"
    exit 1
fi

# Create dump of database
mysqldump  -u$DATABASE_USER  -p$DATABASE_PASSWORD -h 127.0.0.1 --no-tablespaces  $DATABASE_NAME > $BACKUP_HES_DIR/$DATABASE_NAME.sql
################################
 
#Building the Hideez Enterprise Server from the sources

cd $DESTINATION/HES.Web/
mkdir $HES_DIR
dotnet publish -c $VERSION -v d -o $HES_DIR --runtime linux-x64 HES.Web.csproj
if [ $? -eq 0 ]; then
  echo "the application was compiled successfully"
else
  # ups.... 
  echo "application compilation error"
  exit 1
fi
cp $DESTINATION/HES.Web/Crypto_linux.dll $HES_DIR/Crypto.dll

################################



# copying an old json file 
BACKUP_JSON_FILE=$BACKUP_HES_DIR/appsettings.Production.json

cp $BACKUP_JSON_FILE  $JSON_FILE
if [ $? -eq 0 ]; then
        echo "backup appsettings.Production.json to appsettings.Production.json successfully copied"
else
        # ups.... 
        echo "Error copying backup of appsettings.Production.json"
        exit 1
fi


# startiing  service
systemctl start $HESSERVICE
if [ $? -eq 0 ]; then
        echo "HES service is started"
else
    # ups.... 
    echo "HES service start error"
    exit 1
fi

#that's all ..
