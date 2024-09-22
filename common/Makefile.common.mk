#!/usr/bin/make -f
SHELL := /bin/bash
.ONESHELL:

# --- PREREQUISITIES --- #
virtualization-prereq:
	if ! grep -qE "vmx|svm" /proc/cpuinfo 2>&1 >/dev/null; then
		echo "No virtualization enabled on the system"
		exit 1
	fi

vagrant-prereq:
	if ! command -v vagrant 2>&1 >/dev/null; then
		echo "Vagrant is not installed on your system"
		exit 2
	fi

vm-is-up-prereq:
	if [[ "$(shell pgrep -f "network_scenarios.*piraeus")" == "" ]]; then
		echo "Lab VM is NOT running"
		exit 3
	fi

vm-is-down-prereq:
	if [[ "$(shell pgrep -f "network_scenarios.*piraeus")" != "" ]]; then
		echo "Lab VM is ALREADY running"
		exit 3
	fi

inside-labvm-prereq:
	if [[ "$(shell cat /sys/devices/virtual/dmi/id/sys_vendor)" != "QEMU" && "$(shell hostname -s)" != "piraeus" ]]; then
		echo "Not running in Lab VM"
		exit 10
	fi

docker-prereq:
	if ! command -v docker 2>&1 >/dev/null; then
		echo "Docker is not installed on your system"
		exit 4
	fi

ansible-prereq:
	if ! command -v ansible-playbook 2>&1 >/dev/null; then
		echo "Source ansible environment"
		exit 5
	fi

clab-prereq:
	if ! command -v clab 2>&1 >/dev/null; then
		echo "Containerlab is not on your system"
		exit 6
	fi

koko-prereq:
	if ! command -v koko 2>&1 >/dev/null; then
		echo "Ensure koko is installed on your system"
		exit 7
	fi
