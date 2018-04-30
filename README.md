# VictorFSF's dotfiles

Made with [ansible](https://www.ansible.com/) for [`Ubuntu 18.04 LTS`](http://releases.ubuntu.com/18.04/) (bionic).
Must be used locally.

## Deploy

Create and configure the following file:

```bash
group_vars/local  # from group_vars/local.example
```

Execute the `run.sh` file:

```bash
# This will install ansible 2.5.2 if it's not installed;
# Arguments to the ansible-playbook command can be passed here.
./run.sh
```
