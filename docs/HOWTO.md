# How to add new Scenario[^1]

```bash
PROJECT_NAME="<YOUR-SCENARIO-NAME>"
```

[^1] all commands from repository root

## Copy template to new directory

```bash
cp "scenarios/tmpl" "scenarios/${PROJECT_NAME}"
```

## Rename project name in files

* in Makefile
```
sed 's/tmpl/'${PROJECT_NAME}'/' scenarios/${PROJECT_NAME}/Makefile
```

* in compose.yml
```bash
sed 's/tmpl/'${PROJECT_NAME}'/' scenarios/${PROJECT_NAME}/compose.yml
```

* in compose.networks.yml
```bash
sed 's/tmpl/'${PROJECT_NAME}'/' scenarios/${PROJECT_NAME}/compose.networks.yml
```

* in *.clab.yml
```bash
cp scenarios/PROJECT_NAME/tmpl.clab.yml scenarios/${PROJECT_NAME}/${PROJECT_NAME}.clab.yml
sed 's/tmpl/'${PROJECT_NAME}'/' scenarios/${PROJECT_NAME}/${PROJECT_NAME}.clab.yml
```

* for documentation I suggest using `docs/` directory under $PROJECT_NAME

## Methods of standing up the lab

* `containerlab`
* `docker-compose` + `koko`
* `docker-compose` + `docker networks`

### containerlab

Containerlab can be obtained here: [link](https://containerlab.dev/). It allows to start prebuilt images in a topology.
Generally the easiest and least effort option in this repository.

Advantages:
  * easy to configure
  * fast to setup
Drawbacks:
  * if you need the virtual bridge (not p2p) other than default, you need to create it manually
  * cannot configure addresses in topology yaml file

### docker-compose & koko

Docker compose is common option to standup development environments. You can get it here: [link](https://docs.docker.com/compose/).
Resources can depend on each other and you can use templates to make the compose file little more DRY.
To provide p2p networking I am using koko ([link](https://github.com/redhat-nfvpe/koko)).
It is pretty easy to use and ansible does all the work.

Advantages:
  * standard to setup environments with dependencies
  * koko keeps the p2p networking clean and quickly configurable
Drawbacks:
  * requires 2 tools
  * pretty lengthy config file for docker-compose

### docker-compose & docker networks

Docker compose with docker networks is the third option and is most cumbersome and time consuming.
I have not found the option to streamline the process of configuring networks.
And docker networks doesn't work with /30 ipv4 networks if you only want to setup 2 endpoints, cause there is always gateway, even if in bridge internal.

Advantages:
  * one software to deploy everything
Drawbacks:
  * 2 super lengthy config files for docker-compose and networks
  * not real support for /30 networks

## How provisioning works

Provisioning boxes with ansible happens from ansible box ([atsbox](/containers/atsbox/README.md)).
It has all the necessary ansible collections and python dependencies to run ansible.
It also contains keys used to connect to boxes.
If you plan to provision directly from your machine, you can skip building it/including it in topology.

### Files and directories that matter

* `inventory`   -> define here hosts, format: ansible-hosts
* `site.yml`    -> main playbook that configures topology
* `_playbooks/` -> playbooks used to build topology (containerlab, koko)
* `playbooks/`  -> playbooks that do not build topo, but automate tasks
* `roles/`      -> roles of server, put configurations there
* `variables/`  -> variables to share across all playbooks and roles (you can use `group_vars`)

### Fine tune ansible

* you can remove `README.md` and replace with your own
* add your containers to `inventory`
* configure ansible roles and assign them to hosts in `site.yml`
* define variables for roles to use either via `variables/` directory or the ansible way via `group_vars`
