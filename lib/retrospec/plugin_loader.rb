require 'pathname'

module Retrospec
  module PluginLoader
    # Internal: Find any gems containing retrospec plugins and load the main file in them.
    #
    # Returns nothing.
    def self.load_from_gems(version='v1')
      retorspec_plugin_paths = gem_directories.select { |path| (path + File.join('retrospec','plugins')).directory? }
      retorspec_plugin_paths.each do |gem_path|
        Dir[File.join(gem_path,'*.rb')].each do |file|
          load file
        end
      end
    end

    # Internal: Retrieve a list of available gem paths from RubyGems.
    #
    # Returns an Array of Pathname objects.
    def self.gem_directories
      if has_rubygems?
        gemspecs.reject { |spec| spec.name == 'retrospec' }.map do |spec|
          Pathname.new(spec.full_gem_path) + 'lib'
        end
      else
        []
      end
    end

    # Internal: Check if RubyGems is loaded and available.
    #
    # Returns true if RubyGems is available, false if not.
    def self.has_rubygems?
      defined? ::Gem
    end

    # Internal: Retrieve a list of available gemspecs.
    #
    # Returns an Array of Gem::Specification objects.
    def self.gemspecs
      @gemspecs ||= if Gem::Specification.respond_to?(:latest_specs)
                      Gem::Specification.latest_specs
                    else
                      Gem.searcher.init_gemspecs
                    end
    end
  end
end