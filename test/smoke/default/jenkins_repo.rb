describe yum.repo('jenkins') do
  it { should exist }
  it { should be_enabled }
  its('baseurl') { should include 'http://pkg.jenkins.io/redhat' }
end

describe file('/etc/pki/rpm-gpg/RPM-GPG-KEY-jenkins') do
  it { should exist }
  its('owner') { should cmp 'root' }
  its('group') { should cmp 'root' }
  its('mode') { should cmp '0644' }
end
