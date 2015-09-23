require 'retrospec/plugin_loader'
require 'retrospec/plugins/v1'

module Retrospec
  module Plugins
     # loads the plugins (all of them)
     def load_plugins
       Retrospec::PluginLoader.load_from_gems('v1')
     end

     # returns an array of plugin classes by looking in the object space for all loaded classes
     # that start with Retrospec::Plugins::V1
     def plugin_classes
       unless @plugin_classes
         load_plugins
         @plugin_classes = ObjectSpace.each_object(Class).find_all {|c| c.name =~ /Retrospec::Plugins/}
       end
     end

     # returns the first plugin class that supports this module directory
     # not sure what to do when we find multiple plugins
     # would need additional criteria
     def self.discover_plugin(module_path)
        plugin_classes.find {|c| c.send(:valid_module_dir?, module_path) }
     end
  end
end

