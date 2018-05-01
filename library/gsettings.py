#!/usr/bin/python3

import getpass
import json
import re
import subprocess

from ansible.module_utils.basic import AnsibleModule


def _escape_single_quotes(string):
    return re.sub("'", r"'\''", string)


def _split_key(full_key):
    key_array = full_key.split('.')
    schema = '.'.join(key_array[0:-1])
    single_key = key_array[-1]
    return (schema, single_key)


def _get_dbus_bus_address(user):
    try:
        pid = subprocess.check_output([
            'pgrep', '-u', user, 'gnome-session'
        ]).decode().strip()
    except subprocess.CalledProcessError:
        return None

    if pid:
        return subprocess.check_output([
            'grep', '-z',
            '^DBUS_SESSION_BUS_ADDRESS', '/proc/%s/environ' % pid
        ]).decode().strip('\0')


def _process_value(action, schemadir, user, full_key, value=None):
    schema, single_key = _split_key(full_key)

    dbus_addr = _get_dbus_bus_address(user)
    if not dbus_addr:
        command = ['export `/usr/bin/dbus-launch`', ';']
    else:
        command = ['export', dbus_addr, ';']

    command.append('/usr/bin/gsettings')

    if schemadir:
        command.extend(['--schemadir', schemadir])
    command.extend([
        action, schema, single_key
    ])
    if value:
        command.append(value)

    if not dbus_addr:
        command.extend([
            ';', 'kill $DBUS_SESSION_BUS_PID &> /dev/null'
        ])

    return subprocess.check_output([
        'su', '-', user, '-c', " ".join(command)
    ]).decode().strip()


def _set_value(schemadir, user, full_key, value):
    return _process_value(
        'set', schemadir, user, full_key,
        value="'%s'" % _escape_single_quotes(value)
    )


def _get_value(schemadir, user, full_key):
    return _process_value('get', schemadir, user, full_key)


def main():
    module = AnsibleModule(
        argument_spec={
            'state': {'choices': ['present'], 'default': 'present'},
            'user': {'required': False},
            'schemadir': {'required': False},
            'key': {'required': True},
            'value': {'required': True},
        },
        supports_check_mode=True,
    )

    params = module.params
    user = params['user'] or getpass.getuser()
    schemadir = params['schemadir']
    key = params['key']
    value = params['value']
    old_value = _get_value(schemadir, user, key)
    changed = old_value != value

    if changed and not module.check_mode:
        _set_value(schemadir, user, key, value)

    print(json.dumps({
        'user': user,
        'changed': changed,
        'key': key,
        'value': value,
        'old_value': old_value,
    }))


main()
