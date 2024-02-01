# -*- mode: ruby -*-
# vim: set ft=ruby : ts=2 : sts=2 : sw=2 : et :

Vagrant.configure("2") do |config|
  config.vm.define :piraeus do |piraeus|
    piraeus.vm.hostname = "piraeus"
    piraeus.vm.box = "debian/bookworm64"

    piraeus.vm.provider :libvirt do |lv|
      lv.cpus   = 3
      lv.memory = 4096
    end

    piraeus.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive

      apt-get update
      apt-get install -yq ca-certificates curl gnupg jq
      install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/debian/gpg |  gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      chmod a+r /etc/apt/keyrings/docker.gpg

      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null

      apt-get update
      apt-get install -yq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

      usermod -aG docker vagrant

      bash -c "$(wget -qO - https://get.containerlab.dev)"

      _api_call="$(curl "https://api.github.com/repos/redhat-nfvpe/koko/releases/latest")"
      _koko_tag="$(echo "${_api_call}" | jq '.name')"
      _koko_file="$(echo "${_api_call}" | jq '.assets[] | .name' | tr -d '"' | grep "amd64.tar.gz")"
      wget -O /tmp/koko.tar.gz "https://github.com/redhat-nfvpe/koko/releases/download/${_koko_tag}/${_koko_file}"
      tar -xzf /tmp/koko.tar.gz -C /tmp
      mv "/tmp/$(cut -d. -f1 <<<"${_koko_file}")/koko" /usr/local/bin/koko
      chmod 755 /usr/local/bin/koko
      rm -rf /tmp/koko*
      unset _api_call _koko_tag _koko_file
    SHELL
  end
end
