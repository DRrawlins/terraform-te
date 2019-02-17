# Cookbook Name:: chef_nexus
# Test:: install

describe user('nexus') do
  it { should exist }
  its('group') { should eq 'nexus' }
  its('home') { should eq '/home/nexus' }
  its('shell') { should eq '/bin/false' }
end

describe group('nexus') do
  it { should exist }
  its('members') { should include 'nexus' }
end

describe package('java-1.8.0-openjdk') do
  it { should be_installed }
  its('version') { should eq '1.8.0.201.b09-2.fc29' }
end
