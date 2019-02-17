#!/bin/bash
set -x

git clone https://github.com/DRrawlins/chef_role_te.git
sudo dnf install -y ruby ruby-devel
gem install bundle
cd chef_role_te
./install-fed-dependencies.sh
bundle exec berks install
bundle exec berks vendor
mv berks-cookbooks/ cookbooks
sudo bundle install
sudo bundle exec chef-client -z -o chef_role_te
sudo iptables --flush
