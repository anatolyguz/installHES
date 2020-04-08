
# from https://linuxize.com/post/how-to-remove-docker-images-containers-volumes-and-networks/
#Removing All Unused Objects
docker system prune -f

#Removing Docker Containers
docker container prune -f

#Stop and remove all containers
docker container stop $(docker container ls -aq)
docker container rm $(docker container ls -aq)

#Removing Docker Images
docker image prune -f



-Remove all unused network
docker network prune -f


