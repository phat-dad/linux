#!/bin/bash

## SSH Public Key
## Replace this public key with your own public key
n
## SSH Username for Ansible
## Replace this username with the user you'd like to create
ansibleuser='fatman'

## Path for Network Manager Configuration
netmanconf='/etc/NetworkManager/conf.d/manage-all.conf'

echo "This script must be run as root"

osinfo=$(hostnamectl | grep 'Operating System')
echo $osinfo

usercheck=$(sudo cat /etc/passwd | grep -i $ansibleuser)
sudocheck=$(sudo cat /etc/sudoers | grep -i $ansibleuser)

echo "Checking for $ansibleuser Account"

if [[ $usercheck == *$ansibleuser* ]]
then
    echo "$ansibleuser already exists"

else
    echo "Creating user $ansibleuser"
    sudo useradd --create-home $ansibleuser
fi

echo "Creating authorized_keys file for $ansibleuser"

if [ ! -d /home/$ansibleuser/.ssh ]
then
    echo "Creating .ssh directory"
    sudo mkdir /home/$ansibleuser/.ssh
fi

sudo echo $pubkey > /home/$ansibleuser/.ssh/authorized_keys

echo "Setting Permissions"
sudo chown -R $ansibleuser:$ansibleuser /home/$ansibleuser/.ssh
sudo chmod 700 /home/$ansibleuser/.ssh
sudo chmod 600 /home/$ansibleuser/.ssh/authorized_keys

## Set Sudoers Permissions

if [[ $sudocheck == *$ansibleuser* ]]
then
    echo "$ansbileuser exists in sudoers file"
else
    if [[ $osinfo == *"Ubuntu"* ]]
    then
        echo "Adding $ansibleuser to suoders"
        sudo echo "$ansibleuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

    elif [[ $osinfo == *"Rocky"* || $osinfo == *"Red Hat"*  ]]
    then
        echo "Adding $ansibleuser to suoders for Rocky OS"
        sudo echo "$ansibleuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    fi
fi

## General Configuration

## OS Specific Configuration

if [[ $osinfo == *"Ubuntu"* ]]
then
    echo "OS: $osinfo"
	echo "Installing Required Software Packages"
	apt install -y open-vm-tools net-tools network-manager
    echo "Configuring Network Manager"
    sudo echo '[keyfile]' > $netmanconf
    sudo echo 'unmanaged-devices=none' >> $netmanconf
    sudo systemctl enable NetworkManager
    echo "Disabling Netplan"
    sudo systemctl disable --now systemd-networkd systemd-networkd.socket network-dispatcher.service
    sudo service NetworkManager restart
    sudo apt purge -y netplan netplan.io

elif [[ $osinfo == *"Rocky"* || $osinfo == *"Red Hat"*  ]]
then
	echo "OS: $osinfo"
	echo "Disabling Firewall for Local Network"
	sudo systemctl stop firealld
	sudo systemctl disable firewalld
    
    if [[ $osinfo == *"Red Hat"* ]]
    then
        echo "Subscribing to Red Hat Portal"
        sudo subscription-manager register

    fi
    
    echo "Installing Required Software Packages"
	sudo yum install -y open-vm-tools net-tools

fi

echo "Complete!"
echo "Please reboot before proceeding with any additional configuration"
