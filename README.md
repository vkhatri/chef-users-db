usersdb Cookbook
================

This is a [Chef] cookbook to manage Users, Groups and Group Membership on Linux platform using node attribute and LWRP.

## Repository

https://github.com/vkhatri/chef-users-db


## Recipes

- `usersdb::default` - default recipe (required for run_list)


## Data Bag Items

All Users and Groups information must exists in a Databag `node['usersdb']['databag']`.

Below Databag items are required for this cookbook and must exists.

* groups
* users
* group_members

>> Note: All user, group & group members information is defined in data bag items, node attribute or lwrp can only create or delete a user / group.

### Databag Item - groups

Databag item `groups` contains information about **groups**. All groups infromations are stored as a `Hash` under attribute `users` as shown below.

```
{
  "id": "groups",
  "description": "Groups List",
  "groups": {
    "failsafe": {
      "id": 2000
    },
    "foo": {
      "id": 2001
    },
    "dev": {
      "id": 2002,
      "system": true
      "action": "delete"
    }
  }
}
```

Below attributes are supported for a group:

* id (required) - group id
* action (optional, default: `create`) - action for group # options: create, delete, ignore
* system (optional, default: `false`) - whether to create a system group # options: true, false, null


### Databag Item - users

Databag item `users` contains information about **users**. All users infromations are stored as a `Hash` under attribute `groups` as shown below.

```
{
  "id": "users",
  "description": "Users List",
  "users": {
    "failsafe": {
      "id": 2000
    },
    "foo": {
      "password": "$1$2koxPft9$tLyHD6KFEoHvr8BDxhfBk0"
      "full_name": "Foo User",
      "id": 2001,
      "group": "foo",
      "login_shell": "/bin/customshell",
      "home_directory": "/mnt/foo",
      "manage_home": true,
      "public_keys": [
      	"ssh-rsa AAAA….z remoteuser"
      ]
    },
    "app": {
      "full_name": "Service App",
      "id": 2002,
      "group": "app",
      "system": true,
      "action": "delete"
    }
  }
}
```

```
Note: user password must be a hash, you can use openssl to generate a linux user password hash.

$ openssl passwd -1 "PASSWORD"
```

Below attributes are supported for a group:

* id (required) - user id
* group (required) - user primary group
* action (optional, default: `create`) - action for user # options: create, delete, ignore
* system (optional, default: `false`) - whether to create a system user # options: true, false, null
* password (optional, default: `nil`) - user password hash
* full_name (optional, default: `user name`) - user full name
* login_shell (optional, default: `node['usersdb']['default_shell']`) - user login shell
* home_directory (optional, default: `node['usersdb']['default_home']/#{user}`) - user home directory
* manage_home (optional, default: `node['usersdb']['manage_home']`) - whether to manage user home directory
* public_keys (optional, default: `nil`) - adds list of user ssh public key to use `$HOME/.ssh/authorized_keys` file if attribute `node['usersdb']['manage_ssh_dir']` and `node['usersdb']['manage_authorized_keys']` is set


### Databag Item - group_members

Databag item `group_members` contains information about **group members**. All groups, members informations are stored as an `Array` under attribute `group_members` as shown below.

```
{
  "id": "group_members",
  "description": "Groups Members List",
  "group_members": {
    "foo": [
      "foo"
    ],
    "dev": [
      "dev",
      "app"
    ],
    "failsafe": [
      "failsafe"
    ]
  }
}
```

Note: While deleting an user, make sure to delete the user from this Databag item. A Group



## Usage

This cookbook can be used either with limited LWRP or using node attributes.

>> Note: All user, group & group members information is defined in data bag items, node attribute or lwrp can only create or delete a user / group.

### Add Group and Group Members

*Using LWRP*

```
usersdb_group group_name do
end
```

*Using Node Atrbitute - node['groups']*

```
  "default_attributes": {
    "groups": {
      "foo": {},
      "dev": {},
      "failsafe": {}
  }
```


### Remove Group and Group Members

*Using LWRP*

```
usersdb_group group_name do
  action :delete
end
```

*Using Node Atrbitute - node['groups']*

```
  "default_attributes": {
    "groups": {
      "foo": {
      	"action": "delete"
      },
      "dev": {
      	"action": "delete"
      }
  }
```

### Add User

*Using LWRP*

```
usersdb_user user_name do
end
```

*Using Node Atrbitute - node['groups']*

```
  "default_attributes": {
    "users": {
      "foo": {},
      "dev": {},
      "failsafe": {}
  }
```

### Delete User

*Using LWRP*

```
usersdb_user user_name do
  action :delete
end
```

*Using Node Atrbitute - node['groups']*

```
  "default_attributes": {
    "users": {
      "foo": {
      	"action": "delete"
      },
      "dev": {
      	"action": "delete"
      }
  }
```

## Attributes

* `default['usersdb']['disable_cookbook']` (default: `false`): ignore user/group management

* `default['usersdb']['manage_ssh_dir']` (default: `true`): whether to create $HOME/.ssh directory

* `default['usersdb']['manage_authorized_keys']` (default: `true`): whether to add user ssh keys to $HOME/.ssh/authorized_keys from data bag

* `default['usersdb']['manage_home']` (default: `true`): whether to manage user home $HOME directory

* `default['usersdb']['default_home']` (default: `/home`): user $HOME parent directory

* `default['usersdb']['databag']` (default: `usersdb`): databag name

* `default['usersdb']['users']` (default: `{}`): users Hash node attribute

* `default['usersdb']['groups']` (default: `{}`): groups Hash node attribute


## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests (`rake`), ensuring they all pass
6. Write new resource/attribute description to `README.md`
7. Write description about changes to PR
8. Submit a Pull Request using Github


## Copyright & License

Authors:: Virender Khatri and [Contributors]

<pre>
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
</pre>


[Chef]: https://www.chef.io/
[Contributors]: https://github.com/vkhatri/chef-users-db/graphs/contributors
