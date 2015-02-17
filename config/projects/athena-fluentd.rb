require 'erb'
require 'fileutils'
require 'rubygems'

name "athena-fluentd"
maintainer "athenahealth, Inc"
homepage "http://athenahealth.com"
description "Athenahealth Fluentd and plugins"

install_dir     "/opt/athena-fluentd"
build_version   "1.0.4"
build_iteration 0

# creates required build directories
dependency "preparation"

override :ruby, :version => '2.1.5'
override :zlib, :version => '1.2.8'
override :rubygems, :version => '2.2.1'
# CentOS7 needs latest liblzma to build pg and some gems
if ohai['platform_family'] == 'rhel' && ohai['platform_version'].split('.').first.to_i == 7
  override :liblzma, :version => '5.1.2alpha'
end
override :curl, :version => '7.28.0'

# athena-fluentd dependencies/components
dependency "athena-fluentd"
dependency "athena-fluentd-files"
dependency "athena-fluentd-cleanup"

# version manifest file
dependency "version-manifest"

exclude "\.git*"
exclude "bundler\/git"

compress :dmg do
end
