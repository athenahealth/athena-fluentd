require 'erb'
require 'fileutils'
require 'rubygems'

name "athena-fluentd"
maintainer "athenahealth, Inc"
homepage "http://athenahealth.com"
description "Athenahealth Fluentd and plugins"

install_dir     "/opt/athena-fluentd"
build_version   "1.0.3"
build_iteration 1

# creates required build directories
dependency "preparation"

override :zlib, :version => '1.2.8'
override :rubygems, :version => '2.2.1'
# CentOS7 needs latest liblzma to build pg and some gems
if ohai['platform_family'] == 'rhel' && ohai['platform_version'].split('.').first.to_i == 7
  override :liblzma, :version => '5.1.2alpha'
end
override :curl, :version => '7.28.0'

<<<<<<< HEAD:config/projects/athena-fluentd.rb
# athena-fluentd dependencies/components
dependency "athena-fluentd"
dependency "athena-fluentd-files"
#dependency "athena-fluentd-ui"
=======
# td-agent dependencies/components
dependency "td-agent"
dependency "td-agent-files"
dependency "td"
dependency "td-agent-ui"
dependency "td-agent-cleanup"
>>>>>>> 07e94e8... Add td-agent-cleanup software to remove unused files:config/projects/td-agent2.rb

# version manifest file
dependency "version-manifest"

exclude "\.git*"
exclude "bundler\/git"

compress :dmg do
end
