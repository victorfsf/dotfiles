#!/bin/bash

if ! command -v ansible-playbook >/dev/null; then
    # Install ansible
    codename=$(lsb_release -cs)
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu $codename main" | \
        sudo tee /etc/apt/sources.list.d/ansible.list
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
    sudo apt-get update
    sudo apt-get install -y ansible=2.5.2-1ppa~$codename
fi

ssh_private="$HOME/.ssh/id_rsa"
ssh_public="${ssh_private}.pub"

if [[ ! -f "$ssh_private" ]] || [[ ! -f "$ssh_public" ]]; then
    echo "Add your ssh private/public keys to $HOME/.ssh before running ansible!"
    return 1
fi

if [[ "$(stat --format '%a' $ssh_private)" != 400 ]]; then
    sudo chmod 0400 "$ssh_private"
fi
if [[ "$(stat --format '%a' $ssh_public)" != 644 ]]; then
    sudo chmod 0644 "$ssh_public"
fi
if ! ssh-add -L | grep "`cat $ssh_public`" >/dev/null; then
    ssh-add
fi

ansible-playbook -i inventory -l local setup.yml $@
