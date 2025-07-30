#!/usr/bin/env ruby
require 'gli'
require 'json'

class PHP
  def get_namespace(path)
    path = File.expand_path(path)
    start_path = path
    path = File.absolute_path("#{path}/..") until File.file?("#{path}/composer.json") || path == '/'

    raise 'No composer.json was found in any subdirectory' unless File.file?("#{path}/composer.json")

    composer_json = JSON.parse(File.read("#{path}/composer.json"))
    autoload = composer_json&.dig('autoload', 'psr-4') || {}
    autoload_dev = composer_json&.dig('autoload-dev', 'psr-4') || {}
    autoload.merge!(autoload_dev)
    autoload.each_pair do |namespace_prefix, autoload_path|
      autoload_abspath = File.expand_path("#{path}/#{autoload_path}")
      if start_path.start_with?(autoload_abspath)
        relpath = start_path.delete_prefix(autoload_abspath)
        return (namespace_prefix + relpath.split('/').delete_if(&:empty?).join('\\')).chomp('\\')
      end
    end

    raise "No psr-4 namespace found at path #{start_path}"
  end
end

class App
  extend GLI::App

  program_desc 'Describe your application here'

  subcommand_option_handling :normal
  arguments :strict

  desc 'Describe some switch here'
  switch [:s,:switch]

  desc 'Describe some flag here'
  default_value 'the default'
  arg_name 'The name of the argument'
  flag %i[f flagname]

  desc 'Describe php here'
  arg_name 'Describe arguments to php here'
  command :php do |c|
    c.desc 'Describe a switch to php'
    c.switch :s

    c.desc 'Describe a flag to php'
    c.default_value 'default'
    c.action do |global_options,options,args|

      # Your command logic here

      # If you have any errors, just raise them
      # raise "that command made no sense"

      puts "php command ran"
    end
    c.desc 'Get the php psr-4 namespace for the specified directory'
    c.arg 'directory-path',
          default_value: Dir.pwd,
          desc: 'path to the directory, the php file is located in (default: cwd)'
    c.command :namespace do |namespace|
      namespace.action do |_, _, args|
        print PHP.new.get_namespace(args[0])
      end
    end
  end

  pre do |global,command,options,args|
    # Pre logic here
    # Return true to proceed; false to abort and not call the
    # chosen command
    # Use skips_pre before a command to skip this block
    # on that command only
    true
  end

  post do |global,command,options,args|
    # Post logic here
    # Use skips_post before a command to skip this
    # block on that command only
  end

  on_error do |exception|
    # Error logic here
    # return false to skip default error handling
    true
  end
end

exit App.run(ARGV)

