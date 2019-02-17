#!/bin/bash
set -x
export HOME=/root

sudo dnf install -y ruby ruby-devel
gem install bundle
cd /root
git clone https://github.com/DRrawlins/chef_role_te.git
cd /root/chef_role_te
bundle install --system
berks install
berks vendor
mv berks-cookbooks/ cookbooks
chef-client -z -o chef_role_te::default
sudo iptables --flush
