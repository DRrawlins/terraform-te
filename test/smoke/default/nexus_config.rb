describe file('/opt/nexus/bin/nexus.vmoptions') do
  it { should exist }
  its('owner') { should cmp 'nexus' }
  its('group') { should cmp 'nexus' }
  its('mode') { should cmp '0644' }
end
