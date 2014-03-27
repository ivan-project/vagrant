# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "hashicorp/precise32"

    config.vm.network :private_network, ip: "172.70.70.70"
    # config.vm.network :forwarded_port, guest: 80, host: 8080

    config.vm.synced_folder "../", "/var/ivan", id: "vagrant-root", type: "nfs"

    config.vm.provider :virtualbox do |vb|
        # vb.gui = true
        vb.customize ["modifyvm", :id, "--memory", "1024"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant-root", "1"]
    end

    config.ssh.keep_alive = true
    config.ssh.forward_agent = true

    config.vm.provision :shell do |shell|
        shell.path = "shell/bootstrap.sh"
    end

    config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file  = "default.pp"
    end
end
