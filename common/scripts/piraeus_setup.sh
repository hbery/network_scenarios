#!/bin/bash
# vim: ft=bash : ts=4 : sts=4 : sw=4 : et :
#
# Script to quickly setup `piraeus` VM for lab

echo 'export BECOME_PASS="netscenarios"' > .envrc
direnv allow

make prepare-mpls
make containers
make ansible-env
