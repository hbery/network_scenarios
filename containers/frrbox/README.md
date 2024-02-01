# FRR box build

Build for FRR docker container

## Build

```
docker build -t frrbox:latest .
```

## Running

> start container
```
docker run -itd --name frr frrbox:latest
```

> vtysh
```
docker exec -it frrbox vtysh
```

> bash
```
docker exec -it frrbox bash
```
