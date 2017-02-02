require 'yaml'
require_relative 'plugins/v1/module_helpers'
require 'uri'

module Retrospec
  class Config
    include Retrospec::Plugins::V1::ModuleHelpers
    include Retrospec::Plugins::V1
    attr_accessor :config_file

    # we should be able to lookup where the user stores the config map
    # so the user doesn't have to pass this info each time
    def initialize(file=default_config_file, opts={})
      setup_config_file(file)
    end

    # create a blank yaml config file it file does not exist
    def setup_config_file(file=nil)
      if file.nil? or ! File.exists?(file)
        # config does not exist
        setup_config_dir
        dst_file = File.join(default_retrospec_dir, 'config.yaml')
        src_file = File.join(gem_dir,'config.yaml.sample')
        safe_copy_file(src_file, dst_file)
        file = dst_file
      end
      @config_file = file
    end

    # loads the config data into a ruby object
    def config_data
      @config_data ||= YAML.load_file(config_file) || {}
    end

    def self.config_data(file)
      new(file).config_data
    end

    # returns the configs that are only related to the plugin name
    def self.plugin_context(config, plugin_name)
      context = config.select {|k,v| k.downcase =~ /#{plugin_name}/ }
    end

    def gem_dir
      File.expand_path("../../../", __FILE__)
    end

    private

    def default_config_file
      File.join(default_retrospec_dir, 'config.yaml')
    end

    def setup_config_dir
      FileUtils.mkdir_p(File.expand_path(default_retrospec_dir)) unless File.directory?(default_retrospec_dir)
    end
  end
end