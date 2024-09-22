# -*- mode: ruby -*-
# vim: set ft=ruby : ts=2 : sts=2 : sw=2 : et :

Vagrant.configure("2") do |config|
  config.vm.define :piraeus do |piraeus|
    piraeus.vm.hostname = "piraeus"
    piraeus.vm.box = "roboxes/debian12"


    piraeus.vm.synced_folder ".", "/srv",
      type: "rsync", nfs: false,
      group: "vagrant", owner: "vagrant"

    piraeus.vm.provider :libvirt do |lv|
      lv.cpus   = 3
      lv.memory = 4096
    end

    piraeus.vm.provision "bootstrap", type: "shell", run: "once",
      path: "common/scripts/vagrant_provision.sh"

    piraeus.vm.provision "on-reload", type: "shell", run: "always",
      inline: <<-SHELL
        chown -R "net-admin:vagrant" "/srv"
    SHELL
  end
end
