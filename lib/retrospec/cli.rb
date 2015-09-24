require_relative 'plugins'

module Retrospec
  class Cli
    include Retrospec::Plugins

    def self.list_available_plugins
        Retrospec::Cli.new.available_plugins.each do |name, plugin_data|
        puts "#{name}: #{plugin_data['project_url']}"
        puts "\tDescription: #{plugin_data['description']}"
        puts "\tInstallation: gem install #{plugin_data['gem']} --no-rdoc --no-ri"
      end
    end

    def self.list_installed_plugins
      Retrospec::Cli.new.installed_plugins do |spec|
        puts "#{spec.name}"
      end
    end

  end
end