require_relative 'plugins'
require_relative 'exceptions'
require_relative 'config'

module Retrospec
  class Module
    include Retrospec::Plugins
    # module path is the relative or absolute path to the module that we should retrofit
    # opts hash contains additional flags and options that can be user to control the creation of the tests
    # opts[:config_map]
    def initialize(supplied_module_path, plugin_class, opts={})
      # locates the plugin class that can be used with this module directory
      begin
        # load any save data in the config file
        config_data  = Retrospec::Config.config_data(opts[:config_map])
        plugin_data = Retrospec::Config.plugin_context(config_data, plugin_class.send(:plugin_name))
        # merge the passed in options
        plugin_data.merge!(opts)
        # create the instance of the plugin
        plugin = plugin_class.send(:new, supplied_module_path, plugin_data)
        plugin.run
      rescue NoSuitablePluginFoundException
        puts "No gem was found to support this code type, please install a gem that supports this module.".fatal
      end
    end

    # finds a suitable plugin given the name of the plugin or via a supported discovery method
    def find_plugin_type(module_path, name=nil)
      if name
        # when the user wants to create a module give the module type
        discover_plugin_by_name(name)
      else
        discover_plugin(module_path)
      end
    end
  end
end