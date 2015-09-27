require_relative 'plugins'
require 'trollop'
require_relative '../retrospec'
require_relative 'config'

module Retrospec
  class Cli
    include Retrospec::Plugins

    def self.run
      cli = Retrospec::Cli.new
      sub_commands = cli.plugin_map.keys
      cmd_help = sub_commands.join("\n")

      global_opts = Trollop::options do
        version "#{Retrospec::VERSION} (c) Corey Osman"
        banner <<-EOS
A framework to automate your development workflow by generating common files and test patterns.

Usage: retrospec [global options] subcommand [subcommand options]
Available subcommands:
#{cmd_help}

        EOS
        opt :module_path, "The path (relative or absolute) to the module directory" ,
            :type => :string, :required => false, :default => File.expand_path('.')
        opt :config_map, "The global retrospec config file", :type => :string, :required => false, :default => File.expand_path(File.join(ENV['HOME'], '.retrospec', 'config.yaml' ))
        opt :available_plugins, "Show an online list of available plugins", :type => :boolean, :require => false, :short => '-a'
        stop_on sub_commands
      end
      cmd = ARGV.shift # get the subcommand
      if plugin_class = cli.plugin_map[cmd]
        # run the subcommand options but first send the config file and global options to the subcomamnd
        plugin_config = Retrospec::Config.plugin_context(Retrospec::Config.config_data(global_opts[:config_map]), cmd)
        cmd_opts = cli.plugin_map[cmd].send(:cli_options, global_opts.merge(plugin_config))
        opts = global_opts.merge(cmd_opts)
        Retrospec::Module.new(global_opts[:module_path], plugin_class, opts)
      else
        if global_opts[:available_plugins]
          Retrospec::Cli.list_available_plugins
        else
          # this is the default action when no command is entered
          # at a later time we will try and use some magic to guess
          # what the user wants
          Trollop.educate
        end
      end
    end

    def self.list_available_plugins
        Retrospec::Cli.new.available_plugins.each do |name, plugin_data|
        puts "#{name}: #{plugin_data['project_url']}"
        puts "\tDescription: #{plugin_data['description']}"
        puts "\tInstallation: gem install #{plugin_data['gem']} --no-rdoc --no-ri"
      end
    end

    def self.list_installed_plugins
      Retrospec::Cli.new.installed_plugins do |spec|
        puts "#{spec.name}"
      end
    end

  end
end