#/bin/bash


USAGE=`cat << EOF
usage: 
update_HES.sh --p password [otpions]   
 --p password                  password of mysql root  (required parameter!) 
otpions is:
[--r <REPO>]  [--dst <DESTINATION>] [--db <DATABASE_NAME>]  [--b  <BRANCH>]  [--b  <TAG>]  [--v  <VERSION>] [ --hesdir  <HES_DIR>]  [--hesserver <HES-SERVICE>]
where:
 --r <REPO>                    url HES repo/ Default https://gitub.com/HideezGroup/HES  
 --dst <DESTINATION>           destinations of local HES source directory. Default  /opt/src/HES
 --db <DATABASE_NAME>			name of database. Default db
 --b  <BRANCH>                 name of Branch. Default master
 --t  <TAG>                    tag of repo. Default current last commit
 --v  <VERSION>                version of build release or debug Default realese
 --hesdir  <HES_DIR>           path to HES bin directory. Default /opt/HES
 --hesservice  <HES-SERVICE>   name of HES-service. Default HES
EOF
`


MYSQL_ROOT_PASSWORD=""
REPO="https://github.com/HideezGroup/HES"
DESTINATION="/opt/src/HES"
BRANCH="master"
TAG="HEAD"
VERSION="release"
HES_DIR="/opt/HES"
HESSERVICE="HES.service"
DB="db"

while [ -n "$1" ]

do

	if [ -z "$2" ] 
	then
    	echo "ERROR! no values ​​specified after "$1" !"
    	echo "$USAGE"
    	exit 1
	fi

	param="$2"

	case "$1" in

		# -a) echo "Found the -a option";;

		--p)
			MYSQL_ROOT_PASSWORD=$param
			shift ;;
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
		--dbname)
			DATABASE_NAME=$param
			shift ;;

		--) shift
		break ;;
		*) echo "ERROR! $1 is not an option"
		   echo "$USAGE"
		   exit 1
	esac

	shift
done


# count=1
# for param in "$@"
# do
# echo "Parameter #$count: $param"
# count=$(( $count + 1 ))
# done


if [ -z "$MYSQL_ROOT_PASSWORD" ] 
then
    echo "ERROR! no password!"
    echo  "$USAGE"
    exit 1
fi

echo "MYSQL_ROOT_PASSWORD = $MYSQL_ROOT_PASSWORD"
echo "REPO = $REPO"
echo "DESTINATION = $DESTINATION"
echo "BRANCH = $BRANCH"
echo "TAG = $TAG"
echo "VERSION = $VERSION"
echo "HES_DIR = $HES_DIR"
echo "DATABASE_NAME = $DATABASE_NAME"
echo "HESSERVICE = $HESSERVICE"



cd $DESTINATION

git pull
git fetch
git checkout $BRANCH

if [ $? -eq 0 ]; then
  echo "switch to branch $BRANCH"
else
  # ups.... 
  echo "error switchung to branch $BRANCH"
  exit 1
fi



git checkout $TAG
if [ $? -eq 0 ]; then
  echo "switch to tag $TAG"
else
  # ups.... 
  echo "error switchung to tag $TAG"
  exit 1
fi


cat HES.Web/HES.Web.csproj | grep "<Versio\n>"


## to do real upgrade

# stoping  service
systemctl stop $HESSERVICE

# Create backup HES directory
BACKUP_HES_DIR=$HES_DIR.Old

mv $HES_DIR $BACKUP_HES_DIR
if [ $? -eq 0 ]; then
	echo "move to backup HES folder was compiled successfully"
else
    # ups.... 
    echo "move HES foler to backup error"
    exit 1
fi



# Create dump of database
mysqldump  -uroot -p$MYSQL_ROOT_PASSWORD  $DATABASE_NAME > ~/$DATABASE_NAME-$(date +%Y-%m-%d-%H-%M-%S).sql


