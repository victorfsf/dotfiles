#!/bin/bash

if ! command -v ansible-playbook; then
    # Install ansible
    codename=$(lsb_release -a | grep Codename | awk '{print $2}')
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu $codename main" | \
        sudo tee /etc/apt/sources.list.d/ansible.list
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
    sudo apt-get update
    sudo apt-get install -y ansible=2.5.2
fi

ansible-playbook -i inventory -l local setup.yml $@
