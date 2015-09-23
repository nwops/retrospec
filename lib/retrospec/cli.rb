require 'plugins'
module Retrospec
  class Cli
    include Retrospec::Plugins
    def self.list_available_plugins
      available_plugins.each do |name, plugin_data|
        puts "#{name} : #{plugin_data['project_url']}"
        puts "\tDescription: #{plugin_data['description']}"
        puts "\tInstallation: gem install #{plugin_data['data']} --no-rdoc --no-ri"
      end
    end

    def self.list_installed_plugins
      plugin_classes
    end

  end
end