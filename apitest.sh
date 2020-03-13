
SITE="https://hideez.example.com"
EMAIL="admin@hideez.com"
PASSWORD="admin"
#echo '{"email": "'$EMAIL'", "password":"admin"}'

DATA=$(curl -i  --header "Content-Type: application/json"  --request POST --data '{"email":"'$EMAIL'", "password":"'$PASSWORD'"}'  $SITE/api/Identity/Login) 

IDENTITY=$(echo $DATA | sed 's/.*AspNetCore.Identity.Application=\|;.*//g')

VERSION=$(curl  $SITE/api/Dashboard/GetServerVersion --cookie ".AspNetCore.Identity.Application=$IDENTITY")
echo Version = $VERSION

