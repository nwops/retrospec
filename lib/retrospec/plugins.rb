require_relative 'plugin_loader'
require_relative 'plugins/v1'
require 'yaml'
require_relative 'exceptions'

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

     def installed_plugins
       Retrospec::PluginLoader.retrospec_gem_list
     end

     # returns the first plugin class that supports this module directory
     # not sure what to do when we find multiple plugins
     # would need additional criteria
     def discover_plugin(module_path)
        plugin = plugin_classes.find {|c| c.send(:valid_module_dir?, module_path) }
        raise NoSuitablePluginFoundException unless plugin
        plugin
     end

     def discover_plugin_by_name(name)
       plugin = plugin_classes.find {|c| c.send(:plugin_name, name) }
       raise NoSuitablePluginFoundException unless plugin
       plugin
     end

     def available_plugins
        get_remote_data('https://raw.githubusercontent.com/nwops/retrospec/master/available_plugins.yaml')
     end

     def get_remote_data(url)
       require "net/https"
       require "uri"
       uri = URI.parse(url)
       if uri.kind_of?(URI::HTTP) or uri.kind_of?(URI::HTTPS)
         http = Net::HTTP.new(uri.host, uri.port)
         http.use_ssl = true
         #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
         request = Net::HTTP::Get.new(uri.request_uri)
         response = http.request(request)
         YAML.load(response.body)
       else
         {}
       end
     end
  end
end

