require 'retrospec/plugins'
require 'retrospec/exceptions'
require 'retrospec/config'

module Retrospec
  class Module
    include Retrospec::Plugins
    # module path is the relative or absolute path to the module that we should retrofit
    # opts hash contains additional flags and options that can be user to control the creation of the tests
    # opts[:config_map]
    def initialize(supplied_module_path, opts={})
      # locates the plugin class that can be used with this module directory
      begin
        plugin_class = discover_plugin(supplied_module_path)
        config_data  = Retrospec::Config.config_data(opts[:config_map])
        plugin_data = Retrospec::Config.plugin_context(config_data, plugin_class.send(:plugin_name))
        # create the instance of the plugin
        plugin = plugin_class.send(:new, supplied_module_path, plugin_data)
        plugin.run
      rescue NoSuitablePluginFoundException
        puts "No gem was found to support this code type, please install a gem that supports this module.".fatal
      end
    end
  end
end

class String
  def red;            "\033[31m#{self}\033[0m" end
  def green;          "\033[32m#{self}\033[0m" end
  def cyan;           "\033[36m#{self}\033[0m" end
  def yellow;         "\033[33m#{self}\033[0m" end
  def warning;        yellow                   end
  def fatal;          red                      end
  def info;           green                    end
end

