# L3VPN MPLS Scenario

Networking Scenario built with docker-compose and ansible provisioning.

Scenario contains configuration for MPLS L3VPN.

## Topology

![Topology](_docs/l3_vpn_topo_dark.png#gh-dark-mode-only)
![Topology.](_docs/l3_vpn_topo_light.png#gh-light-mode-only)

> ~drawn with [Excalidraw](https://excalidraw.com)

## Prerequisities

* docker-compose

## Running

> Setup topology
```
docker compose --profile topo up -d
```

> Provision
```
# setup inventory
./_scripts/setup-inventory.sh

# enter ansible container
docker exec -it ansible-tower_mgmt bash

# execute 
ansible-playbook -i /srv/ansible/inventory.yml /srv/ansible/jobs/topo.yml
```
