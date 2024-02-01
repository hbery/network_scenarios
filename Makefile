#!/usr/bin/make -f
##Makefile :: network_scenarios
##---

ROOT := $(shell git rev-parse --show-toplevel)

.PHONY: help clab-up clab-dn compose-up compose-dn netcompose-up netcompose-dn containers ansible-env clean-env
.ONESHELL:
.DEFAULT: help
.SILENT:

REBUILD := no

##usage: make [command]
##

## help             Print this help
help: Makefile
	@sed -n 's/^##//p' $<

##---

## clab-up          Deploy Containerlab
clab-up: docker-prereq clab-prereq ansible-prereq
	echo "" | ANSIBLE_DISPLAY_SKIPPED_HOSTS=0 \
		ANSIBLE_STDOUT_CALLBACK=yaml \
		ansible-playbook "$(ROOT)/ansible/_playbooks/setup-containerlab.yml" \
		--extra-vars="{ 'ansible_become_password': '$${BECOME_PASS}', 'ci_plaction': 'create' }"
	docker exec -it ansible-tower.mgmt ansible-playbook site.yml

## clab-dn          Destroy Containerlab
clab-dn: docker-prereq clab-prereq ansible-prereq
	echo "" | ANSIBLE_DISPLAY_SKIPPED_HOSTS=0 \
		ANSIBLE_STDOUT_CALLBACK=yaml \
		ansible-playbook "$(ROOT)/ansible/_playbooks/setup-containerlab.yml" \
		--extra-vars="{ 'ansible_become_password': '$${BECOME_PASS}', 'ci_plaction': 'destroy' }"

## compose-up       Deploy project as docker compose (without using docker networks)
compose-up: docker-prereq koko-prereq ansible-prereq
	docker compose --profile=topo --file compose.yml up -d
	ANSIBLE_DISPLAY_SKIPPED_HOSTS=0 \
		ANSIBLE_STDOUT_CALLBACK=yaml \
		ansible-playbook -K "$(ROOT)/ansible/_playbooks/setup-links.yml" \
		--extra-vars="{ 'ansible_become_password': '$${BECOME_PASS}', 'ci_plaction': 'create' }"

## compose-dn       Destroy project as docker compose (without using docker networks)
compose-dn: docker-prereq koko-prereq ansible-prereq
	ANSIBLE_DISPLAY_SKIPPED_HOSTS=0 \
		ANSIBLE_STDOUT_CALLBACK=yaml \
		ansible-playbook -K "$(ROOT)/ansible/_playbooks/setup-links.yml" \
		--extra-vars="{ 'ansible_become_password': '$${BECOME_PASS}', 'ci_plaction': 'destroy' }"
	docker compose --profile=topo --file compose.yml down

## netcompose-up    Deploy project as docker compose (with using docker networks)
netcompose-up: docker-prereq
	docker compose --profile=topo --file compose.yml --file compose.networks.yml up -d

## netcompose-dn    Destroy project as docker compose (with using docker networks)
netcompose-dn: docker-prereq
	docker compose --profile=topo --file compose.yml --file compose.networks.yml down

##---

## containers       (Re)Build containers for the lab
containers: docker-prereq
	./scripts/build_containers.sh

## prepare-mpls     Setup kernel modules and options for MPLS routing (as `sudo`)
prepare-mpls:
	sudo ./scripts/prepare_mpls.sh

## ansible-env      (Re)Build Ansible python environment; `make REBUILD=yes ansible-env` to rebuild virtualenv
ansible-env:
	REBUILD=$(REBUILD) ./scripts/build_python_environment.sh

## clean-env        Clean ansible-env python virtualenv
clean-env:
	rm -rf ansible-env/


##
# --- PREREQUISITIES --- #
docker-prereq:
	if ! command -v docker 2>&1 >/dev/null; then
		echo "Docker is not installed on your system"
		exit 1
	fi

ansible-prereq:
	if ! command -v ansible-playbook 2>&1 >/dev/null; then
		echo "Source ansible environment"
		exit 2
	fi

clab-prereq:
	if ! command -v clab 2>&1 >/dev/null; then
		echo "Containerlab is not on your system"
		exit 3
	fi

koko-prereq:
	if ! command -v koko 2>&1 >/dev/null; then
		echo "Ensure koko is installed on your system"
		exit 4
	fi

