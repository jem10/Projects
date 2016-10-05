#
# Cookbook Name:: RvmRuby
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

#apt_update do
#  action :update
#  only_if { node['platform_family'].eql?("debian") }
#end

apt_update  'all platforms' do
  action :update
  only_if { node['platform_family'].eql?("debian") }
end

package ['git', 'curl'] do
  action :install
end

bash 'install_rvm' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
   gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
   curl -sSL https://github.com/rvm/rvm/tarball/stable -o rvm-stable.tar.gz
   mkdir rvm && cd rvm
   tar --strip-components=1 -xzf /tmp/rvm-stable.tar.gz
   ./install --auto-dotfiles
   source /tmp/.rvm/scripts/rvm
   cd
   source /etc/profile.d/rvm.sh
   rvm get head
   rvm requirements
   rvm install 2.3.0
  EOH
end


