# Ansible box build

Ansible docker container

## Build

```
docker build -t atsbox:latest -f Containerfile .
```

## Running

> start container
```
docker run -itd --name ats atsbox:latest
```

> bash
```
docker exec -it ats bash
```
