login to docker hub
```
docker login
```

for build local 
```
docker build . -t <user_name>/<image_name>:latest  -t <user_name>/<image_name>:[tag] .
```

run and test

```
docker run -it <user_name>/<image_name>   /bin/sh
```

push to docker hub

```
docker push <user_name>/<image_name>:[tag] 
docker push <user_name>/<image_name>:latest
```
