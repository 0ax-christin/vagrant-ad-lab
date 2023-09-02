# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

config_yaml = YAML.load_file('provision/vagrant.yml')

# Check if vagrant winrm missing and if so install
# unless Vagrant.has_plugin?("vagrant-winrm")
#     puts 'Installing vagrant-winrm Plugin...'
#     system('vagrant plugin install vagrant-winrm')
# end

unless Vagrant.has_plugin?("vagrant-windows-sysprep")
    puts 'Installing vagrant-windows-sysprep Plugin...'
    system('vagrant plugin install vagrant-windows-sysprep')
end

Vagrant.configure("2") do |cfg|
    
    fqdn = config_yaml['common']['domain_name']

    ## AD DC config
    dc_hostname = config_yaml['win2022dc']['vm_name']
    dc_ip = config_yaml['win2022dc']['ip']

    ## Windows1 config
    win1_hostname = config_yaml['windows1']['vm_name']
    win1_ip = config_yaml['windows1']['ip']

    ## Windows2 config
    win2_hostname = config_yaml['windows2']['vm_name']
    win2_ip = config_yaml['windows2']['ip']

    cfg.vm.define "DC" do |config|
        config.vm.box = config_yaml['win2022dc']['box']
        config.vm.hostname = dc_hostname
        config.vm.boot_timeout = 1000

        # Use the plaintext WinRM transport and force it to use basic authentication.
        # NB this is needed because the default negotiate transport stops working
        # after the domain controller is installed.
        # see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
        config.winrm.transport = :plaintext
        config.winrm.basic_auth_only = true
        config.winrm.retry_limit = 30
        config.winrm.retry_delay = 10
        
        config.vm.provider :virtualbox do |v, override|
            v.gui = true
            v.cpus = config_yaml['win2022dc']['cpus']
            v.memory = config_yaml['win2022dc']['mem_size']
            v.customize ["modifyvm", :id, "--vram", 32]
            v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
            v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
        end
        
        config.vm.network :private_network, :ip => dc_ip
 
        config.vm.provision "windows-sysprep"
        config.vm.provision "shell", reboot: true
 
        # Configure keyboard/language/timezone etc.
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-windows/base-setup.ps1 en-US"
        config.vm.provision "shell", reboot: true 

        # Configure DNS
        #config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/networking/network-setup-scheduler.ps1 network-setup-dc.ps1 dns_entries.csv"
        #config.vm.provision "shell", reboot: true

        # Install Forest and Certificate Services
        # Create forest root
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-ad/install-forest.ps1 forest-variables.json"
        config.vm.provision "shell", reboot: true

        #Reboot so that scheduled task runs
        #config.vm.provision "shell", reboot: true

    end
    
    cfg.vm.define "win10ent1" do |config|
        config.vm.box = config_yaml['windows1']['box']
        config.vm.hostname = win1_hostname
        config.vm.boot_timeout = 1000
        # Use the plaintext WinRM transport and force it to use basic authentication.
        # NB this is needed because the default negotiate transport stops working
        # after the domain controller is installed.
        # see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
        config.winrm.transport = :plaintext
        config.winrm.basic_auth_only = true
        config.winrm.retry_limit = 30
        config.winrm.retry_delay = 10

        config.vm.provider :virtualbox do |v, override|
            v.gui = true
            v.cpus = config_yaml['windows1']['cpus']
            v.memory = config_yaml['windows1']['mem_size']
            v.customize ["modifyvm", :id, "--vram", 32]
            v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
            v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
        end

        config.vm.network :private_network, :ip => win1_ip
        config.vm.provision "windows-sysprep"
        config.vm.provision "shell", reboot: true

        #Install Chocolatey
        config.vm.provision "install-chocolatey", type: "shell", path: "scripts/caller.ps1", args: "scripts/setup-windows/install-chocolatey.ps1"
        config.vm.provision "shell", reboot: true

        # Configure keyboard/language/timezone etc.
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-windows/base-setup.ps1 en-US"
        config.vm.provision "shell", reboot: true
        
    end

    cfg.vm.define "win10ent2" do |config|
        config.vm.box = config_yaml['windows2']['box']
        config.vm.hostname = win2_hostname
        config.vm.boot_timeout = 1000

        # Use the plaintext WinRM transport and force it to use basic authentication.
        # NB this is needed because the default negotiate transport stops working
        # after the domain controller is installed.
        # see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
        config.winrm.transport = :plaintext
        config.winrm.basic_auth_only = true
        config.winrm.retry_limit = 30
        config.winrm.retry_delay = 10

        config.vm.provider :virtualbox do |v, override|
            v.gui = true
            v.cpus = config_yaml['windows2']['cpus']
            v.memory = config_yaml['windows2']['mem_size']
            v.customize ["modifyvm", :id, "--vram", 32]
            v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
            v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
        end
        config.vm.network :private_network, :ip => win2_ip
        config.vm.provision "windows-sysprep"
        config.vm.provision "shell", reboot: true

        #Install Chocolatey
        config.vm.provision "install-chocolatey", type: "shell", path: "scripts/caller.ps1", args: "scripts/setup-windows/install-chocolatey.ps1"
        config.vm.provision "shell", reboot: true

        # Configure keyboard/language/timezone etc.
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-windows/base-setup.ps1 en-US"
        config.vm.provision "shell", reboot: true
    end
end
