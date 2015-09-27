require 'pathname'

module Retrospec
  module PluginLoader
    # Internal: Find any gems containing retrospec plugins and load the main file in them.
    #
    # Returns nothing.
    def self.load_from_gems(version='v1')
      gem_directories.each do |gem_path|
        Dir[File.join(gem_path,'*.rb')].each do |file|
          load file
        end
      end
    end

    # Internal: Retrieve a list of available gem paths from RubyGems.
    # filter out the main retrospec gem, then filter out any plugin that is
    # not a retrospec gem.
    #
    # Returns an Array of Pathname objects.
    def self.gem_directories
      dirs = []
      if has_rubygems?
       dirs = gemspecs.reject { |spec| spec.name == 'retrospec' }.map do |spec|
          lib_path = File.expand_path(File.join(spec.full_gem_path,'lib'))
          lib_path if File.exists? File.join(lib_path,'retrospec','plugins')
        end
      end
      dirs.reject { |dir| dir.nil? }
    end


    # returns a list of retrospec gem plugin specs
    def self.retrospec_gem_list
      gemspecs.reject { |spec| spec.name == 'retrospec' or ! File.directory?(File.join(spec.full_gem_path,'lib','retrospec','plugins')) }
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