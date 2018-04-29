# VictorFSF's dotfiles

Made with [ansible](https://www.ansible.com/) for `Ubuntu 18.04 LTS`.
Must be used locally.

## Deploy

Create the following files from their templates:

```bash
inventory  # from inventory.example
group_vars/local  # from group_vars/local.example
```

Execute the `run.sh` file:

```bash
# This will install ansible 2.5.2 if it's not installed;
# Arguments to the ansible-playbook command can be passed here.
./run.sh
```
