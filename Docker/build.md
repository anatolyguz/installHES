for build local 
```
docker build . -t <user_name>/<image_name>:latest  -t <user_name>/<image_name>:[tag] .
```

push to docker hub

```
docker push <user_name>/<image_name>:[tag] 
docker push <user_name>/<image_name>:latest
```
