module Retrospec
  module Plugins
    module V1
      class Plugin
      attr_accessor :module_path, :module_name, :module_dir_name, :config
      attr_reader   :files, :plugin_name

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

      def run
        raise NotImplementedError
      end

    end
    end
  end

end
