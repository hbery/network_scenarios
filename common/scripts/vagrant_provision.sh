#!/bin/bash
# vim: ft=bash : ts=4 : sts=4 : sw=4 : et :
# shellcheck disable=SC2016
#
# Script to provision Vagrant Lab VM

_installPkgsFn () {
    export DEBIAN_FRONTEND=noninteractive

    apt-get update
    apt-get install -yq \
        ca-certificates \
        python3-venv \
        direnv \
        gnupg \
        curl \
        make \
        vim \
        git \
        fzf \
        jq \
        jo
}

_installDockerFn () {
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list >/dev/null

    apt-get update
    apt-get install -yq \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
}

_installContainerlabFn () {
    bash -c "$(wget -qO - https://get.containerlab.dev)"
}

_installKokoFn () {
    local _api_call _koko_tag _koko_filename _dl_url
    _api_call="$(curl -s "https://api.github.com/repos/redhat-nfvpe/koko/releases/latest")"
    _koko_tag="$(echo "${_api_call}" | jq -r '.name')"
    _koko_filename="$(echo "${_api_call}" | jq -r '.assets[].name' | grep "amd64.tar.gz")"
    _dl_url="$(echo "${_api_call}" | jq -r '.assets[] | select( .name == "'"${_koko_filename}"'" ) | .browser_download_url')"
    wget -O "/tmp/koko.tar.gz" "${_dl_url}"
    tar -xzf "/tmp/koko.tar.gz" -C "/tmp"
    mv "/tmp/$(sed -n 's/.tar.gz//p' <<<"${_koko_filename}")/koko" "/usr/local/bin/koko"
    chmod 755 /usr/local/bin/koko
    rm -rf /tmp/koko*
}

_addUserFn () {
    # add `net-admin` user
    useradd \
        --comment "Network Scenarios Admin" \
        --home-dir "/home/net-admin" \
        --create-home \
        --groups "sudo,docker,vagrant" \
        --shell "/bin/bash" \
        net-admin

    # set password for `net-admin` (openssl passwd -6 -salt "rounds=600000\$$(openssl rand -hex 16)" <password>) # see README
    usermod \
        -p '$6$rounds=600000$243d646f436776ee$6XhSj0z3DL.ZI5yVppEVrZuqOYf0Zxy4b.AXbfoC2D8ilpNDpDKRS8UVZ1jQTUbPMsCHJ3chBtM9xn3e.SYhc1' \
        net-admin

    # use the same ssh-key for `net-admin` as `vagrant`
    mkdir -p "/home/net-admin/.ssh"
    cp "/home/vagrant/.ssh/authorized_keys" "/home/net-admin/.ssh/authorized_keys"

    # setup environment
    chown -R "net-admin:net-admin" "/home/net-admin/.ssh"
}

_setupUserEnv () {
    cp "/srv/.rcfile" "/home/net-admin/.bash_profile"
    echo 'eval "$(direnv hook bash)"' >> "/home/net-admin/.bash_profile"

    chown "net-admin:net-admin" "/home/net-admin/.bash_profile"
    chown "net-admin:vagrant" "/srv"
}

_prepareLabFn () {
    pushd "/srv" || exit 1
    git config --global --add safe.directory /srv
    make prepare-mpls

    su --login net-admin <<- EOS
pushd "/srv" || exit 1
git config --global --add safe.directory /srv
echo 'export BECOME_PASS="netscenarios"' > .envrc
direnv allow

make containers
make ansible-env
popd || exit 1
EOS
    popd || exit 1
}

_mainFn () {
    _installPkgsFn
    _installDockerFn
    _installContainerlabFn
    _installKokoFn
    _addUserFn
    _setupUserEnv
    _prepareLabFn
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _mainFn "${@:-}"
fi
