name "athena-fluentd-files"
#version '' # git ref

dependency "athena-fluentd"

# This software setup athena-fluentd related files, e.g. etc files.
# Separating file into athena-fluentd.rb and athena-fluentd-files.rb is for speed up package building

build do
  block do
    # setup related files
    pkg_type = project.packager.id.to_s
    install_path = project.install_dir # for ERB
    project_name = project.name # for ERB
    project_name_snake = project.name.gsub('-', '_') # for variable names in ERB
    project_name_snake_upcase = project_name_snake.upcase
    gem_dir_version = "2.1.0"

    template = ->(*parts) { File.join('templates', *parts) }
    generate_from_template = ->(dst, src, erb_binding, opts={}) {
      mode = opts.fetch(:mode, 0755)
      destination = dst.gsub('athena-fluentd', project.name)
      FileUtils.mkdir_p File.dirname(destination)
      File.open(destination, 'w', mode) do |f|
        f.write ERB.new(File.read(src)).result(erb_binding)
      end
    }

    # copy pre/post scripts into omnibus path (./package-scripts/athena-fluentdN)
    FileUtils.mkdir_p(project.package_scripts_path)
    Dir.glob(File.join(project.package_scripts_path, '*')).each { |f|
      FileUtils.rm_f(f) if File.file?(f)
    }
    # templates/package-scripts/athena-fluentd/xxxx/* -> ./package-scripts/athena-fluentdN
    Dir.glob(template.call('package-scripts', 'athena-fluentd', pkg_type, '*')).each { |f|
      package_script = File.join(project.package_scripts_path, File.basename(f))
      generate_from_template.call package_script, f, binding, mode: 0755
    }

    # setup plist / init.d file
    if ['pkg', 'dmg'].include?(pkg_type)
      # templates/athena-fluentd.plist.erb -> INSTALL_PATH/athena-fluentd.plist
      plist_path = File.join(install_path, "athena-fluentd.plist")
      generate_from_template.call plist_path, template.call("athena-fluentd.plist.erb")
    else
      # templates/etc/init.d/xxxx/athena-fluentd -> ./resources/etc/init.d/athena-fluentd
      initd_file_path = File.join(project.resources_path, 'etc', 'init.d', project.name)
      generate_from_template.call initd_file_path, template.call('etc', 'init.d', pkg_type, 'athena-fluentd'), binding, mode: 0755
    end

    # setup /etc/athena-fluentd
    ['athena-fluentd.conf', 'athena-fluentd.conf.tmpl', ['logrotate.d', 'athena-fluentd.logrotate'], ['prelink.conf.d', 'athena-fluentd.conf']].each { |item|
      conf_path = File.join(project.resources_path, 'etc', 'athena-fluentd', *([item].flatten))
      generate_from_template.call conf_path, template.call('etc', 'athena-fluentd', *([item].flatten)), binding, mode: 0644
    }

    ["athena-fluentd", "athena-fluentd-gem", "athena-fluent-cat"].each { |command|
      sbin_path = File.join(install_path, 'usr', 'sbin', command)
      # templates/usr/sbin/yyyy.erb -> INSTALL_PATH/usr/sbin/yyyy
      generate_from_template.call sbin_path, template.call('usr', 'sbin', "#{command}.erb"), binding, mode: 0755
    }

    FileUtils.remove_entry_secure(File.join(install_path, 'etc'), true)
    # ./resources/etc -> INSTALL_PATH/etc
    FileUtils.cp_r(File.join(project.resources_path, 'etc'), install_path)
  end
end
