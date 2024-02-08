# L3VPN MPLS Scenario

Networking Scenario built with docker-compose and ansible provisioning.

Scenario contains configuration for MPLS L3VPN.

## Topology

![Topology](docs/l3_vpn_topo_dark.png#gh-dark-mode-only)
![Topology.](docs/l3_vpn_topo_light.png#gh-light-mode-only)

> ~drawn with [Excalidraw](https://excalidraw.com)

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

> for now fully working is below
```
# to stand up
make clab-up

# to destroy
make clab-dn
```
