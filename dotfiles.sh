#!/bin/bash

dotfiles() {
    local code
    cd "${DOTFILES_DIR:-$HOME/.dotfiles}"
    ansible-playbook -i inventory -l local setup.yml $@
    code="$?"
    cd - >/dev/null

    return "$code"
}
