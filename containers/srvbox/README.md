# SRV box build

Server docker container

## Build

```
docker build -t srvbox:latest -f Containerfile .
```

## Running

> start container
```
docker run -itd --name srv srvbox:latest
```

> bash
```
docker exec -it srv bash
```
