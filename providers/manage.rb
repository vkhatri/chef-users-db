#
# Cookbook Name:: usersdb
# Provider:: manage
#
# Copyright 2014, Virender Khatri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

def whyrun_supported?
  true
end

action :manage do
  new_resource.updated_by_last_action(setup_resources)
end

action :disable do
  Chef::Log.warn('cookbook userdb is disabled, not managing user/group resources')
  new_resource.updated_by_last_action(false)
end

protected

def setup_resources
  collect_groups
  collect_users
  delete_user
  create_group
  create_user
  delete_group
  manage_group_members
end

def load_current_resource
  fail "update attribute node['usersdb']['databag'] with databag name" unless node['usersdb']['databag']

  fail "data bag does not exists - #{node['usersdb']['databag']}" unless Chef::DataBag.list.key?(node['usersdb']['databag'])

  # fetch users information from databag
  databag_users_item = data_bag_item(node['usersdb']['databag'], 'users')
  fail "missing data bag item - users, in data bag #{node['usersdb']['databag']}" unless databag_users_item

  @users_db = databag_users_item['users'] || fail("data bag item - users, in data bag #{node['usersdb']['databag']} is missing attribute - users, check documentation")

  # fetch groups information from databag
  databag_groups_item = data_bag_item(node['usersdb']['databag'], 'groups')
  fail "missing data bag item - groups, in data bag #{node['usersdb']['databag']}" unless databag_groups_item

  @groups_db = databag_groups_item['groups'] || fail("data bag item - groups, in data bag #{node['usersdb']['databag']} is missing attribute - groups, check documentation")

  # fetch users information from databag
  databag_group_members_item = data_bag_item(node['usersdb']['databag'], 'group_members')
  fail "missing data bag item - group_members, in data bag #{node['usersdb']['databag']}" unless databag_group_members_item

  @group_members_db = databag_group_members_item['group_members'] || fail("data bag item - group_members, in data bag #{node['usersdb']['databag']} is missing attribute - group_members, check documentation")

  @create_users = []
  @delete_users = []
  @create_groups = []
  @member_groups = []
  @delete_groups = []
end

def collect_groups
  userdb_groups.each do |group, options|
    group_info = @groups_db[group]

    # collect group members
    group_members = @group_members_db[group]

    if options['action'] == 'ignore'
      Chef::Log.warn("group=#{group}, ignored")

    elsif options['action'] == 'delete'
      # validate group
      fail "group=#{group}, group not found in data bag" unless group_info

      # validate group_members
      fail "group=#{group}, group members must be an array" unless group_members.is_a?(Array)

      @delete_groups.push group

      @delete_users += group_members unless group_members.empty?

    else
      # validate group
      fail "group=#{group}, group not found in data bag" unless group_info

      # validate group_members
      fail "group=#{group}, group members must be an array" unless group_members.is_a?(Array)

      @create_groups.push group

      @create_users += group_members unless group_members.empty?
    end
  end
end

def create_group
  (@create_groups + @member_groups - @delete_groups).each do |group_name|
    group_info = @groups_db[group_name]

    # create group
    group group_name do
      gid group_info['id']
      system true if group_info['system']
      append true
      action :create
    end
  end
end

def delete_group
  @delete_groups.each do |group_name|
    group group_name do
      action :remove
    end
  end
end

def collect_users
  userdb_users.each do |user, options|
    user_info = @users_db[user]

    if options['action'] == 'ignore'
      Chef::Log.warn("user=#{user}, ignored")

    elsif options['action'] == 'delete'
      @delete_users.push user

    else
      # validate user
      fail "user=#{user}, user not found in data bag" unless user_info

      # validate user primary group information is available
      fail "user=#{user}, user primary group is not set" unless user_info['group']

      # create user primary group
      @member_groups.push user_info['group']
    end
  end
end

def create_user
  (@create_users - @delete_users).each do |user_name|
    # if a user is set to be removed
    # in data bag
    user_info = @users_db[user_name]

    # create user
    if user_name == 'root'
      user user_name do
        supports manage_home: false
        password user_info['password'] if user_info['password']
        action :manage
      end

    elsif user_info['action'] == 'remove'
      # if a user is set to be removed
      # in data bag
      user user_name do
        supports manage_home: true if user_info['manage_home'] || node['usersdb']['manage_home']
        action :remove
      end

    else
      user_home_directory = user_info['home_directory'] || ::File.join(node['usersdb']['default_home'], user_name)

      if user_info['action'] == 'disable'
        case node['platform_family']
        when 'debian'
          user_login_shell = '/usr/sbin/nologin'
        when 'rhel', 'fedora'
          user_login_shell = '/sbin/nologin'
        end
      else
        user_login_shell  = user_info['login_shell'] || node['usersdb']['default_shell']
      end

      user user_name do
        supports manage_home: true if user_info['manage_home'] || node['usersdb']['manage_home']
        comment user_info['full_name'] || user_name
        gid user_info['group']
        password user_info['password'] if user_info['password']
        uid user_info['id']
        home user_home_directory
        shell user_login_shell
        system user_info['system'] # ~FC048
        action :create
      end

      # might not be necessary, need
      # to check
      directory user_home_directory do
        owner user_name
        group user_info['group']
        mode 0700
        only_if { user_info['action'] != 'disable' && node['usersdb']['manage_home'] }
      end

      # create .ssh directory
      directory ::File.join(user_home_directory, '.ssh') do
        user user_name
        group user_info['user_group_name']
        mode 0700
        only_if { user_info['action'] != 'disable' && node['usersdb']['manage_ssh_dir'] }
      end

      # validate public keys
      fail "user=#{user}, user authorized_keys attribute :public_keys must be an array" if user_info['public_keys'] && !user_info['public_keys'].is_a?(Array)

      # create authorized_keys file
      template ::File.join(user_home_directory, '.ssh', 'authorized_keys') do
        source 'authorized_keys.erb'
        user user_name
        group user_info['user_group_name']
        mode 0600
        variables(:public_keys => user_info['public_keys'])
        only_if { node['usersdb']['manage_ssh_dir'] && node['usersdb']['manage_authorized_keys'] && user_info['public_keys'] }
      end
    end
  end
end

def delete_user
  @delete_users.each do |user_name|
    user user_name do
      supports manage_home: true
      action :remove
    end
  end
end

def manage_group_members
  # Group Users Membership for node.groups
  (@create_groups - @delete_groups).each do|group_name|
    group_members = @group_members_db[group_name] - @delete_users
    group group_name do
      members group_members
    end unless group_members.nil?
  end
end

#####

# collect group resources
def userdb_group_resources
  run_context.resource_collection.select do |resource|
    resource.is_a?(Chef::Resource::UsersdbGroup)
  end
end

def userdb_groups
  hash = {}
  userdb_group_resources.reduce({}) do |_h, resource|
    hash[resource.name] ||= {}
    hash[resource.name] = resource.send('options')
  end

  hash.merge!(node['groups'])
  hash
end

# collect user resources
def userdb_user_resources
  run_context.resource_collection.select do |resource|
    resource.is_a?(Chef::Resource::UsersdbUser)
  end
end

def userdb_users
  hash = {}
  userdb_user_resources.reduce({}) do |_h, resource|
    hash[resource.name] ||= {}
    hash[resource.name] = resource.send('options')
  end

  hash.merge!(node['users'])
  hash
end
