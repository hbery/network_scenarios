#!/bin/bash
#
# build all containers in this project

_project_root="$(git rev-parse --show-toplevel)"

pushd "${_project_root}" &>/dev/null || exit 1

# build new containers
while read -r _container; do
    _container_name="$(basename "${_container}")"

    pushd "${_container}" &>/dev/null || exit 1
    echo "*** Building ${_container_name}.."
    docker build -t "${_container_name}:latest" -f Containerfile .
    popd &>/dev/null || exit 1
done < <(find "${_project_root}" -type d -name "*box")

# remove dangling
declare -a _dangling_containers
mapfile -t _dangling_containers < <(docker image ls --filter "dangling=true" --quiet)
if [[ "${_dangling_containers[*]}" != "" ]]; then
    docker image rm "${_dangling_containers[@]}"
fi

popd &>/dev/null || exit 1
