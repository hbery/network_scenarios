# Network Test Scenarios

Networking Scenario built with docker-compose/containerlab and ansible provisioning.

## Prerequisities

* docker-compose
* containerlab
* koko
* ansible

## Running

> run `make` to get all the options
```
make
# or
make help
```

## Setup

> spin up vagrant vm and login to it
>   (or if you run on your local machine, skip this)
```
# provision box
make vmup

# login to box
#   * user: net-admin
#   * pass: netscenarios
make vml
```

> setup environment
```
cd /srv
cp .envrc.example .envrc

# put the password of a user to var BECOME_PASS
vim .envrc

# enable direnv to export vars
direnv allow

# build containers
make prepare-mpls
make containers
make ansible-env
env_activate
```

### to run scenario with `containerlab`
```
# to stand up
make PROJECT=<SCENARIO> run-clab-up

# to destroy
make PROJECT=<SCENARIO> run-clab-dn
```

### to run scenario with `docker-compose` and `koko`
```
# to stand up
make PROJECT=<SCENARIO> run-compose-up

# to destroy
make PROJECT=<SCENARIO> run-compose-dn
```

### to run scenario fully with `docker-compose` and `docker networks`
```
# to stand up
make PROJECT=<SCENARIO> run-netcompose-up

# to destroy
make PROJECT=<SCENARIO> run-netcompose-dn
```
