require 'trollop'
require_relative 'module_helpers'

module Retrospec
  module Plugins
    module V1
      class Plugin
        attr_accessor :module_path, :config_data
        attr_reader   :plugin_name

        # by including this module we are getting helper code that will assist
        # with creating files and rendering template.
        # for a list of available functions please see the following lik
        # https://github.com/nwops/retrospec/blob/master/lib/retrospec/plugins/v1/module_helpers.rb
        include Retrospec::Plugins::V1::ModuleHelpers

        def initialize(supplied_module_path='.',config={})
          @config_data = config
          @module_path = File.expand_path(supplied_module_path)
        end

        # validates that the module meets the plugins criteria
        # returns boolean true if module files are valid, false otherwise
        # validates module directory fits the description of this plugin
        # this is used in the discover method
        def self.valid_module_dir?(dir)
          if ! File.exist?(dir)
            false
          else
            module_files ||= Dir.glob("#{dir}/**/*#{file_type}")
            if module_files.length < 1
              false
            else
              true
            end
          end
        end

        # used to display subcommand options to the cli
        # the global options are passed in for your usage
        def self.cli_options(global_opts)
          Trollop::options do
          end
        end

        # the name of the plugin that will be sent to the cli
        # the cli turns this into a subcommand where the user interacts with your plugin
        def self.plugin_name
          self.name.split('::').last.downcase
        end

        # sets the config which should be a hash
        def config=(config_map)
          @config = config_map
        end

        # the main file type that is used to help discover what the module is
        def self.file_type
          raise NotImplementedError
        end

        # the main entry point that is called when retrospec is run
        # using this as the starting point after initialization
        def run
          raise NotImplementedError
        end
      end
    end
  end
end