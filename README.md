usersdb Cookbook
================

This is a [Chef] cookbook to manage Users, Groups and Group Membership on Linux platform using node attribute and LWRP.

## Repository

https://github.com/vkhatri/chef-usersdb


## Requirements

None.

## Recipes

- `usersdb::default`      - default recipe (required for run_list)


## Data Bag Items

All Users and Groups information must exists in a Databag `node['usersdb']['databag']`.

Below Databag items are required for this cookbook.

* groups
* users
* group_members

### Databag Item - groups

Info not yet added.

### Databag Item - users

Info not yet added.

### Databag Item - group_members

Info not yet added.

## Usage

This cookbook can be used either with limited LWRP or using node attributes.

### Add Group and Group Members

Info not yet added.

### Remove Group and Group Members

Info not yet added.

### Add User

Info not yet added.

### Delete User

Info not yet added.

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
[Contributors]: https://github.com/vkhatri/chef-usersdb/graphs/contributors
