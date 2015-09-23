module Retrospec
  module Plugin
    module V1
      attr_accessor :module_path, :module_name, :module_dir_name, :config
      attr_reader   :files, :plugin_name

      # validates that the module meets the plugins criteria
      # returns boolean true if module files are valid, false otherwise
      # validates module directory fits the description of this plugin
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

      # sets the config which should be a hash
      def config=(config_map)
        @config = config_map
      end
      # returns a array of supported files type extensions ie. ['rb', 'pp', 'go']
      def self.supported_files
        raise NotImplementedError
      end

      # the name of the plugin, defaults to the name of the class
      def self.plugin_name
        self.class.downcase
      end

      # the main file type that is used to help discover what the module is
      def self.file_type
        raise NotImplementedError
      end

      # the description of the plugin
      def description
        raise NotImplementedError
      end

      # generates the scaffolding of the plugin type
      # this is called after the pre-hook
      def generate_plugin_files
        raise NotImplementedError
      end

      def run
        raise NotImplementedError
      end

      # returns a list of files that can be further processed
      def files

      end
    end
  end
end
