#!/usr/bin/make -f
##Makefile :: network_scenarios :: l3vpn_c
##---

SHELL = /bin/bash
ROOT := $(shell git rev-parse --show-toplevel)

PROJ_NAME := l3vpn_c
PROJ_PATH := $(ROOT)/scenarios/$(PROJ_NAME)

.PHONY: help clab-up clab-dn compose-up compose-dn netcompose-up netcompose-dn
.ONESHELL:
.DEFAULT: help
.SILENT:

ANSIBLE_COMMAND := ANSIBLE_CONFIG=$(ROOT)/ansible.cfg ANSIBLE_DISPLAY_SKIPPED_HOSTS=0 ANSIBLE_STDOUT_CALLBACK=yaml ansible-playbook

##usage: make [command]
##

## help             Print this help
help: Makefile
	@sed -n 's/^##//p' $<

##---

include $(ROOT)/common/Makefile.common.mk

## clab-up          Deploy Containerlab
clab-up: docker-prereq clab-prereq ansible-prereq
	echo "" | $(ANSIBLE_COMMAND) "$(PROJ_PATH)/ansible/_playbooks/setup-containerlab.yml" \
		--extra-vars="{ 'ansible_become_password': '$${BECOME_PASS}', 'ci_plaction': 'create' }"
	docker exec -it ansible-tower.mgmt ansible-playbook site.yml

## clab-dn          Destroy Containerlab
clab-dn: docker-prereq clab-prereq ansible-prereq
	echo "" | $(ANSIBLE_COMMAND) "$(PROJ_PATH)/ansible/_playbooks/setup-containerlab.yml" \
		--extra-vars="{ 'ansible_become_password': '$${BECOME_PASS}', 'ci_plaction': 'destroy' }"

## compose-up       Deploy project as docker compose (without using docker networks)
compose-up: docker-prereq koko-prereq ansible-prereq
	docker compose --profile=topo --file compose.yml up -d
	$(ANSIBLE_COMMAND) -K "$(PROJ_PATH)/ansible/_playbooks/setup-links.yml" \
		--extra-vars="{ 'ansible_become_password': '$${BECOME_PASS}', 'ci_plaction': 'create' }"

## compose-dn       Destroy project as docker compose (without using docker networks)
compose-dn: docker-prereq koko-prereq ansible-prereq
	$(ANSIBLE_COMMAND) -K "$(PROJ_PATH)/ansible/_playbooks/setup-links.yml" \
		--extra-vars="{ 'ansible_become_password': '$${BECOME_PASS}', 'ci_plaction': 'destroy' }"
	docker compose --profile=topo --file compose.yml down

## netcompose-up    Deploy project as docker compose (with using docker networks)
netcompose-up: docker-prereq
	docker compose --profile=topo --file compose.yml --file compose.networks.yml up -d

## netcompose-dn    Destroy project as docker compose (with using docker networks)
netcompose-dn: docker-prereq
	docker compose --profile=topo --file compose.yml --file compose.networks.yml down

##
