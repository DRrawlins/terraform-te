describe systemd_service('jenkins') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe file('/var/lib/jenkins/init.groovy.d/basic-security.groovy') do
  it { should_not exist }
end

describe file('/var/lib/jenkins/secrets/initialAdminPassword') do
  it { should_not exist }
end
