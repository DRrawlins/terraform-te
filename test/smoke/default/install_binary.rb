describe directory('/opt/tmp') do
  it { should exist }
  its('owner') { should cmp 'nexus' }
  its('group') { should cmp 'nexus' }
end

describe directory('/opt/nexus') do
  it { should exist }
  its('owner') { should cmp 'nexus' }
  its('group') { should cmp 'nexus' }
end

describe directory('/opt/sonatype-work') do
  it { should exist }
  its('owner') { should cmp 'nexus' }
  its('group') { should cmp 'nexus' }
end

describe file('/opt/tmp/nexus-3.15.2-01-unix.tar.gz') do
  it { should_not exist }
end

describe directory('/opt/tmp/nexus-3.15.2-01-unix') do
  it { should_not exist }
end

describe directory('/opt/tmp/nexus-3.15.2-01') do
  it { should_not exist }
end

describe directory('/opt/tmp/nexus') do
  it { should_not exist }
end

describe directory('/opt/tmp/sonatype-work') do
  it { should_not exist }
end
