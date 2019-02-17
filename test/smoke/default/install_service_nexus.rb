describe file('/etc/systemd/system/nexus.service') do
  it { should exist }
  its('owner') { should cmp 'nexus' }
  its('group') { should cmp 'nexus' }
  its('mode') { should cmp '0644' }
end

describe directory('/var/log/nexus') do
  it { should exist }
  its('owner') { should cmp 'nexus' }
  its('group') { should cmp 'nexus' }
  its('mode') { should cmp '0640' }
end

describe file('/var/log/nexus/nexus.log') do
  it { should exist }
  its('owner') { should cmp 'nexus' }
  its('group') { should cmp 'nexus' }
  its('mode') { should cmp '0755' }
end
