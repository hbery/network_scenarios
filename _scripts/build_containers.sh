#!/bin/bash
#
# build all containers

_project_root="$(git rev-parse --show-toplevel)"

pushd "${_project_root}" &>/dev/null || exit 1

# build new containers
for _container in $(find "${_project_root}" -type d -name "*box"); do
    _container_name="$(basename "${_container}")"

    pushd "${_container}" &>/dev/null || exit 1
    echo "*** Building ${_container_name}.."
    docker build -t "${_container_name}:latest" .
    popd &>/dev/null || exit 1
done

# remove dangling
docker image rm $(docker image ls --filter "dangling=true" --quiet)

popd &>/dev/null || exit 1
