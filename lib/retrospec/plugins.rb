# frozen_string_literal: true

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

    def excluded_classes
      [Retrospec::Plugins::V1::ContextObject, Retrospec::Plugins::V1::Plugin]
    end

    # returns an array of plugin classes by looking in the object space for all loaded classes
    # that start with Retrospec::Plugins::V1
    def plugin_classes
      unless @plugin_classes
        load_plugins
        @plugin_classes = ObjectSpace.each_object(Class).find_all { |c| c.to_s =~ /^Retrospec::Plugins/ } - excluded_classes || []
      end
      @plugin_classes
    end

    def plugin_map
      @plugin_map ||= Hash[plugin_classes.map { |gem| [gem.send(:plugin_name), gem] }]
    end

    def installed_plugins
      Retrospec::PluginLoader.retrospec_gem_list
    end

    # returns the first plugin class that supports this module directory
    # not sure what to do when we find multiple plugins
    # would need additional criteria
    def discover_plugin(module_path)
      plugin = plugin_classes.find { |c| c.send(:valid_module_dir?, module_path) }
      raise NoSuitablePluginFoundException unless plugin

      plugin
    end

    def discover_plugin_by_name(name)
      plugin = plugin_classes.find { |c| c.send(:plugin_name, name) }
      raise NoSuitablePluginFoundException unless plugin

      plugin
    end

    def gem_dir
      File.expand_path('../..', __dir__)
    end

    def available_plugins
      get_remote_data('https://raw.githubusercontent.com/nwops/retrospec/master/available_plugins.yaml')
    rescue SocketError
      puts 'Using cached list of available plugins, use internet to get latest list.'
      YAML.load_file(File.join(gem_dir, 'available_plugins.yaml'))
    end

    def get_remote_data(url)
      require 'net/https'
      require 'uri'
      uri = URI.parse(url)
      if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        YAML.safe_load(response.body)
      else
        {}
      end
    end
  end
end
