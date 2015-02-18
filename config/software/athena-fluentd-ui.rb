name "athena-fluentd-ui"
#version '' # git ref

dependency "fluentd-ui"
dependency "athena-fluentd-files"

# for 'athena-fluentd-ui' command

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

    sbin_path = File.join(install_path, 'usr', 'sbin', 'athena-fluentd-ui')
    # templates/usr/sbin/yyyy.erb -> INSTALL_PATH/usr/sbin/yyyy
    generate_from_template.call sbin_path, template.call('usr', 'sbin', "athena-fluentd-ui.erb"), binding, mode: 0755
  end
end
