require 'yaml'
require 'retrospec/plugins/v1/module_helpers'
require 'retrospec/plugins/v1/template_helpers'
require 'uri'

module Retrospec
  class Config
    include Retrospec::Plugins::V1::ModuleHelpers
    include Retrospec::Plugins::V1::
    attr_accessor :config_file

    # we should be able to lookup where the user stores the config map
    # so the user doesn't have to pass this info each time
    def initialize(file=nil, opts={})
      config_file = file
    end

    # create a blank yaml config file it file does not exist
    def config_file=(file)
      unless file.nil? or File.exists?(file)
        # config does not exist
        setup_config_dir
        new_file = File.join(default_retrospec_dir, 'config.yaml.sample')
        safe_create_file(new_file, ''.to_yaml)
        file = new_file
      end
      @config_file = file
    end

    # loads the config data into a ruby object
    def config_data
      @config_data ||= YAML.load_file(config_file)
    end

    def self.config_data(file)
      self.class.new(file).config_data
    end

    # returns the configs that are only related to the plugin name
    def self.plugin_context(config, plugin_name)
      config.select {|k,v| k.downcase =~ /#{plugin_name}/ }
    end

    private

    def setup_config_dir
      FileUtils.mkdir_p(File.expand_path(default_retrospec_dir)) unless Directory.exists?(default_retrospec_dir)
    end
    # def get_remote_data
    #   uri = URI.parse(my_possible_url)
    #   if uri.kind_of?(URI::HTTP) or uri.kind_of?(URI::HTTPS)
    #     # do your stuff
    #   end
    #   require "net/https"
    #   require "uri"
    #
    #   uri = URI.parse("http://google.com/")
    #
    #   # Shortcut
    #   response = Net::HTTP.get_response(uri)
    #
    #   # Will print response.body
    #   Net::HTTP.get_print(uri)
    #
    #   uri = URI.parse("https://secure.com/")
    #   http = Net::HTTP.new(uri.host, uri.port)
    #   http.use_ssl = true
    #   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #
    #   request = Net::HTTP::Get.new(uri.request_uri)
    #
    #   response = http.request(request)
    #   response.body
    # end
  end
end