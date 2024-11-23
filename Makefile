#!/usr/bin/make -f
##Makefile :: network_scenarios
##---

SHELL = bash
ROOT := $(shell git rev-parse --show-toplevel)

.PHONY: help run-% list vmup vmdn vmsh vmcp vm-setup containers prepare-mpls ansible-env clean-env
.ONESHELL:
.DEFAULT: help
.SILENT:

##usage: make [parameter=value ..] [command]
##

##parameters:
##  PROJECT          => Scenario to run
PROJECT ?= l3vpn_c
##  REBUILD          => Whether to rebuild the ansible python environment or not
REBUILD := no

# labvm specific
##  LABVM_USER       => What user to use to provision the VM
LABVM_USER ?= net-admin
##  LABVM_PASS       => What password to use for the user for the provisioned VM
LABVM_PASS ?= netscenarios
##  LABVM_HOST       => What host to target to provision in Vagrantfile
LABVM_HOST ?= piraeus
##  LABVM_SSH_CONFIG => What file to use as ssh_config to login to the box
LABVM_SSH_CONFIG ?= $(ROOT)/.network-scenarios.ssh_config

##
##commands:

##  help             Print this help
help: Makefile
	@sed -n 's/^##//p' $<

##---

include $(ROOT)/common/Makefile.common.mk

##  run-<CMD>        Run `make` <CMD> in specific scenario (`run-help` shows available options)
run-%:
	$(MAKE) -C scenarios/$(PROJECT) $(subst run-,,$@)

##  list             List possible scenarios
list:
	echo "projects:"
	while read -r proj; do echo "  * $$proj"; done  < <(ls -1 scenarios/)

##---

##  vmup             Provision Lab VM
vmup: virtualization-prereq vagrant-prereq vm-is-down-prereq
	vagrant up

##  vmdn             Destroy Lab VM
vmdn: vm-is-up-prereq
	vagrant destroy --force
	rm -f "$(LABVM_SSH_CONFIG)"

##  vmsh             Login to Lab VM as `net-admin`
vmsh: vm-is-up-prereq vm-sshconfig-prereq
	ssh -F "$(LABVM_SSH_CONFIG)" "$(LABVM_USER)@$(LABVM_HOST)"

##  vmcp             Sync code from host to LabVM
vmcp: vm-sshconfig-prereq
	rsync \
		--archive --compress --verbose \
		--exclude=".vagrant/" \
		--exclude="$(shell basename "$(LABVM_SSH_CONFIG)")" \
		--rsh="ssh -F $(LABVM_SSH_CONFIG)" \
		"$(ROOT)/" \
		"$(LABVM_USER)@$(LABVM_HOST):/srv/"

##  vm-setup         Setup LabVM `piraeus` [*]
#     * only works with default setup
vm-setup: inside-labvm-prereq
	echo 'export BECOME_PASS="$(LABVM_PASS)"' > .envrc
	direnv allow
	$(MAKE) prepare-mpls
	$(MAKE) containers
	$(MAKE) ansible-env

##---

##  containers       (Re)Build containers for the lab
containers: docker-prereq
	./common/scripts/build_containers.sh

##  prepare-mpls     Setup kernel modules and options for MPLS routing (as `sudo`)
prepare-mpls:
	sudo ./common/scripts/prepare_mpls.sh

##  ansible-env      (Re)Build Ansible python environment; `make REBUILD=yes ansible-env` to rebuild virtualenv
ansible-env:
	REBUILD=$(REBUILD) ./common/scripts/build_python_environment.sh

##  clean-env        Clean ansible-env python virtualenv
clean-env:
	rm -rf $(ROOT)/ansible-env/

##

# --- ADDITIONAL PREREQUISITIES --- #
vm-sshconfig-prereq:
	if [[ ! -f "$(LABVM_SSH_CONFIG)" ]]; then
		vagrant ssh-config > "$(LABVM_SSH_CONFIG)"
		sed -i 's/User vagrant/User net-admin/' "$(LABVM_SSH_CONFIG)"
	fi
