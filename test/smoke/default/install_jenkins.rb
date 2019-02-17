# Cookbook Name:: chef_jenkins
# Test:: install

describe package('unzip') do
  it { should be_installed }
  its('version') { should eq '6.0-42.fc29' }
end

describe package('jenkins') do
  it { should be_installed }
  its('version') { should eq '2.164-1.1' }
end

describe package('java-1.8.0-openjdk') do
  it { should be_installed }
  its('version') { should eq '1.8.0.201.b09-2.fc29' }
end
