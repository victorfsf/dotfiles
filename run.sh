#!/bin/bash

if ! command -v ansible-playbook >/dev/null; then
    # Install ansible
    sudo apt-get install software-properties-common
    sudo apt-add-repository ppa:ansible/ansible -y
    sudo apt-get update
    sudo apt-get install -y ansible
fi

ssh_private="$HOME/.ssh/id_rsa"
ssh_public="${ssh_private}.pub"

if [[ ! -f "$ssh_private" ]] || [[ ! -f "$ssh_public" ]]; then
    echo "Add your ssh private/public keys to $HOME/.ssh before running ansible!"
    exit 1
fi

if [[ "$(stat --format '%a' $ssh_private)" != 400 ]]; then
    sudo chmod 0400 "$ssh_private"
fi
if [[ "$(stat --format '%a' $ssh_public)" != 644 ]]; then
    sudo chmod 0644 "$ssh_public"
fi

key=(`cat $ssh_public`)
if ! ssh-add -L | grep "${key[1]}" >/dev/null; then
    ssh-add "$ssh_private"
    code="$?"
    [[ "$code" -ne 0 ]] && exit "$code"
fi

if ! command -v dotfiles >/dev/null; then
    source "$(dirname $0)/dotfiles.sh"
fi

dotfiles $@
