#
# Cookbook Name:: MYsql
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

apt_update  'all platforms' do
  action :update
  only_if { node['platform_family'].eql?("debian") }
end

mysqlpass = data_bag_item("mysql", "rtpass.json")

mysql_service 'mysql' do
  port '3306'
  version '5.5'
  initial_root_password mysqlpass["password"]
  action [:create, :start]
end

