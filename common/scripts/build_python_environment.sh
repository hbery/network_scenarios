#!/bin/bash
#
# (re)build python environment for ansible

_project_root="$(git rev-parse --show-toplevel)"

if [ "${REBUILD}" = "yes" ]; then
    rm -rf "${_project_root}/ansible-env/"
fi

if [ ! -d "./ansible-env" ]; then
    python3 -m venv "${_project_root}/ansible-env"
fi

source "${_project_root}/ansible-env/bin/activate" \
    && pip install --upgrade pip \
    && pip install -r "${_project_root}/ansible-requirements.txt" \
    && ansible-galaxy collection install \
        --requirements-file "${_project_root}/ansible-collections.yml" \
        --collections-path "${_project_root}/ansible-env/lib/$(python --version | sed -nr 's/Python (.+)\.(.+)\.(.+)/python\1.\2/p')/site-packages/ansible_collections/"

