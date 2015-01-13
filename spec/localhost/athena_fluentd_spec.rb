require 'spec_helper'

describe package('athena-fluentd') do
  it { should be_installed }
end

describe file('/etc/init.d/athena-fluentd') do
  it { should be_executable }
  it { should be_mode 755 }
end

describe file('/etc/athena-fluentd') do
  it { should be_directory }
end

describe file('/etc/athena-fluentd/athena-fluentd.conf') do
  it { should be_file }
  it { should contain '</match>' }
  it { should contain '</source>' }
end

%w(athena-fluentd athena-fluentd-gem athena-fluentd-ui).each do |command|
  describe file("/usr/sbin/#{command}") do
    it { should be_executable }
    it { should be_mode 755 }
  end
end

describe file('/opt/athena-fluentd') do
  it { should be_directory }
end

describe group('athena-fluentd') do 
  it { should exist }
end

describe user('athena-fluentd') do 
  it { should exist }
end

describe user('athena-fluentd') do 
  it { should belong_to_group 'athena-fluentd' }
end

# Plugin tests.

describe command('/usr/sbin/athena-fluentd-gem list') do
  %W(td td-monitoring mongo webhdfs rewrite-tag-filter s3 scribe).each { |plugin|
    its(:stdout) { should match Regexp.new("fluent-plugin-#{plugin}") }
  }
end
