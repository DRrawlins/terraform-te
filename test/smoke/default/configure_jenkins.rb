describe user('jenkins') do
  it { should exist }
  its('group') { should eq 'jenkins' }
  its('home') { should eq '/var/lib/jenkins' }
end

describe group('jenkins') do
  it { should exist }
  its('members') { should include 'jenkins' }
end

describe directory('/var/lib/jenkins') do
  it { should exist }
  its('owner') { should cmp 'jenkins' }
  its('group') { should cmp 'jenkins' }
  its('mode') { should cmp '0755' }
end

describe directory('/var/lib/jenkins/init.groovy.d') do
  it { should exist }
  its('owner') { should cmp 'jenkins' }
  its('group') { should cmp 'jenkins' }
  its('mode') { should cmp '0755' }
end

describe directory('/usr/lib/jenkins') do
  it { should exist }
  its('owner') { should cmp 'jenkins' }
  its('group') { should cmp 'jenkins' }
  its('mode') { should cmp '0755' }
end

describe directory('/var/cache/jenkins') do
  it { should exist }
  its('owner') { should cmp 'jenkins' }
  its('group') { should cmp 'jenkins' }
  its('mode') { should cmp '0755' }
end

describe directory('/var/run/jenkins') do
  it { should exist }
  its('owner') { should cmp 'jenkins' }
  its('group') { should cmp 'jenkins' }
  its('mode') { should cmp '0755' }
end

describe directory('/var/log/jenkins') do
  it { should exist }
  its('owner') { should cmp 'jenkins' }
  its('group') { should cmp 'jenkins' }
  its('mode') { should cmp '0755' }
end

describe file('/etc/sysconfig/jenkins') do
  it { should exist }
  its('owner') { should cmp 'root' }
  its('group') { should cmp 'root' }
  its('mode') { should cmp '0600' }
end
