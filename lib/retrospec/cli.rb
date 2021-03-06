require_relative 'plugins'
require 'optimist'
require_relative '../retrospec'
require_relative 'config'

module Retrospec
  class Cli
    include Retrospec::Plugins

    def self.run
      cli = Retrospec::Cli.new
      # get the list of plugins and provide the plugin name as sub commands
      sub_commands = cli.plugin_map.keys
      cmd_help = sub_commands.join("\n")

      global_opts = Optimist::options do
        version "#{Retrospec::VERSION} (c) Corey Osman"
        banner <<-EOS
A framework to automate your development workflow by generating common files and test patterns.

Usage: retrospec [global options] plugin [plugin options]
Available subcommands:
#{cmd_help}

        EOS
        opt :enable_overwrite, "Enable overwriting of files, will prompt for each file",
            :type => :boolean, :default => false
        opt :enable_overwrite_all, "Always overwrites files without prompting",
            :type => :boolean, :default => false
        opt :module_path, "The path (relative or absolute) to the module directory" ,
            :type => :string, :required => false, :default => File.expand_path('.')
        opt :config_map, "The global retrospec config file", :type => :string, :required => false, :default => File.expand_path(File.join(ENV['HOME'], '.retrospec', 'config.yaml' ))
        opt :available_plugins, "Show an online list of available plugins", :type => :boolean, :require => false, :short => '-a'
        stop_on sub_commands
      end
      cmd = ARGV.shift # get the subcommand
      # these variables are used in the module helpers to determine if we should overwrite files
      ENV['RETROSPEC_OVERWRITE_ALL'] = global_opts[:enable_overwrite_all].to_s if global_opts[:enable_overwrite_all]
      ENV['RETROSPEC_OVERWRITE_ENABLE'] = global_opts[:enable_overwrite].to_s if global_opts[:enable_overwrite]

      if plugin_class = cli.plugin_map[cmd]
        # this is what generates the cli options for the plugin
        # this is also the main entry point that runs the plugin's cli
        global_config = Retrospec::Config.config_data(global_opts[:config_map])
        plugin_name   = plugin_class.send(:plugin_name)
        plugin_config = Retrospec::Config.plugin_context(global_config, plugin_name)
        plugin_class.send(:run_cli, global_opts, global_config, plugin_config)
      else
        if global_opts[:available_plugins]
          Retrospec::Cli.list_available_plugins
        else
          # this is the default action when no command is entered
          # at a later time we will try and use some magic to guess
          # what the user wants
          Optimist.educate
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