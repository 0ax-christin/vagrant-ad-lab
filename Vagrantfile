## CSEC-742 Computing Systems Security
## Lab 1 - AD Vulnerable Environment Building
## Group: qwerty
## Members:
## - Christin Alex
## - Rashed Alnuman
## - Saleem
## 3 Machines are setup: 2 Windows Desktops and 1 Windows Server to make a simple Active Directory Network
## Windows Server will act as the Domain Controller and DNS Server
## The environment build is made using Infrastructure as Code tool, Vagrant and Powershell Scripts
## Vagrant provisions the virtual machines on whatever provider (VirtualBox, libvirt, VMWare) based on the configuration in the Vagrantfile
## Which specifies the version and server images using a format called "boxes", boxes are obtained from "https://app.vagrantup.com/boxes/search"
## The Vagrantfile also specifies how the network is setup, their IPs, gateways, etc, it allows configuration of how much resources each VM should as per a specific provider
## After the VMs are setup using providers and the network is setup, vagrant allows the use of provisioners(Shell, Ansible, Puppet, Chef) to automate the initial setup of the machines
## In this lab, the provisioner of Shell was used for Windows, this means the setup of Active Directory, initial windows setup, Creation of users was all completed using Powershell scripts found in the 'scripts' directory
## Vagrant for the setup of the VMs, has an admin account called vagrant which after setup is complete is removed from each machine

## Under 'provision/' are the values for the variables required for things such as network and VM setup, Active Directory installation options and parameters, as well as the specific Users, OUs, and Service Accounts to be added to the domain
## In 'provision/vagrant.yml', the details for the provisioning of boxes, such as the number of CPUs, and memory to allocate, what box to use, what Static IPs to give are all specified for each machine
## This file gives an overview of the network and the details of the machines being setup that vagrant will use in this file

## 'provision/variables/forest-variables.json' is used by the Powershell scripts to fill specific parameters required when setting up Active Directory such as Domain name
## 'provision/variables/users.json' is used by the Powershell scripts that are meant to create accounts in the newly setup active directory

## 'scripts/caller.ps1' is the main powershell script which calls other Powershell scripts with their parameters, it makes sure the working directory is C:\vagrant when calling scripts
## Vagrant, when setting up VMs shares this folder with the VMs, this is utilized to run all provision scripts

## In terms of networks, there is a NAT network and a private network with static IPs, the NAT network is used by Vagrant and the private network is specified by us to host the machines
## Only Step 18 which was the setup of Group Policy has not been automated so far
## Steps 25-28 are done manually to ensure that everything has been installed as intended

# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

config_yaml = YAML.load_file('provision/vagrant.yml')

# Required to prep vms for deployment, to give them unique SIDS
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
        # specifies the hostname as per requirements of labs to qwerty-DC
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
        # Creates static IP as per vagrant.yml
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

        # Create OU, users/Admin users and service accounts as per users.json, all users created are added to Groups OU except Administrator and Guest
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-ad/create-OUs-and-accounts.ps1 forest-variables.json"

        # Set up SMB as per Step 16
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-ad/setup-smb.ps1"

        #Reboot so that scheduled task runs
        #config.vm.provision "shell", reboot: true
        # Disable/Delete Vagrant User to finish setup
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-ad/remove-vagrant.ps1"

    end
    
    cfg.vm.define "win10ent1" do |config|
        config.vm.box = config_yaml['windows1']['box']
        # specifies the hostname as per requirements of labs to Windows1Machine
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
        # Specify static IP, as well as gateway and dns as DC
        config.vm.network :private_network, :ip => win1_ip, :gateway => dc_ip, :dns => dc_ip
        config.vm.provision "windows-sysprep"
        config.vm.provision "shell", reboot: true

        #Install Chocolatey
        config.vm.provision "install-chocolatey", type: "shell", path: "scripts/caller.ps1", args: "scripts/setup-windows/install-chocolatey.ps1"

        # Configure keyboard/language/timezone etc.
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-windows/base-setup.ps1 en-US"
        config.vm.provision "shell", reboot: true

        # Add local MyWindows1 Account
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-windows/create-users.ps1"

        # Change DNS to point to DC
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/networking/network-setup-scheduler.ps1 network-setup-workstation.ps1"

        # Join Computer to DC with login as Admin as per Step 21
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-ad/join-domain.ps1 forest-variables.json OU=Groups"
        config.vm.provision "shell", reboot: true

        # Remove/Disable Vagrant User to finish setup
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-ad/remove-vagrant.ps1"
        config.vm.provision "shell", reboot: true
        
    end

    cfg.vm.define "win10ent2" do |config|
        config.vm.box = config_yaml['windows2']['box']
        # specifies the hostname as per requirements of labs to Windows2Machine
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
        # Specify static IP, as well as gateway and dns as DC
        config.vm.network :private_network, :ip => win2_ip, :gateway => dc_ip, :dns => dc_ip
        config.vm.provision "windows-sysprep"
        config.vm.provision "shell", reboot: true

        #Install Chocolatey
        config.vm.provision "install-chocolatey", type: "shell", path: "scripts/caller.ps1", args: "scripts/setup-windows/install-chocolatey.ps1"
        config.vm.provision "shell", reboot: true

        # Configure keyboard/language/timezone etc.
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-windows/base-setup.ps1 en-US"
        config.vm.provision "shell", reboot: true
    
        # Add local MyWindows2 Account
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-windows/create-users.ps1"
        
        # Change DNS to point to DC
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/networking/network-setup-scheduler.ps1 network-setup-workstation.ps1"

        # Join Computer to DC with login as Admin as per Step 21
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-ad/join-domain.ps1"
        config.vm.provision "shell", reboot: true

        # Add Domain Accounts and Local MyWIndows accounts to Admin Group, Enable Local Admin with password as per Step 23 and 24
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-ad/add-to-local-admin.ps1"

        # Remove/Disble Vagrant User To finish setup
        config.vm.provision "shell", path: "scripts/caller.ps1", args: "scripts/setup-ad/remove-vagrant.ps1"
        config.vm.provision "shell", reboot: true
    end
end
