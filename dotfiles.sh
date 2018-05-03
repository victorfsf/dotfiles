#!/bin/bash

dotfiles() {
    local code
    cd "$(dirname $0)"
    ansible-playbook -i inventory -l local setup.yml $@
    code="$?"
    cd -

    return "$code"
}
