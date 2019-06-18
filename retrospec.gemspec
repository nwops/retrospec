# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'retrospec/version'
Gem::Specification.new do |spec|
  spec.name = "retrospec"
  spec.version       = Retrospec::VERSION
  spec.authors       = ['Corey Osman']
  spec.email         = ['corey@nwops.io']

  spec.summary = "A devops framework for automating your development workflow"
  spec.date = "2017-04-17"
  spec.homepage = "http://github.com/nwops/retrospec"
  spec.description = "Retrospec is a framework that allows the automation of repetitive file creation with just about any kind of language through the use of a pluggable architecture."
  spec.license       = 'MIT'
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.extra_rdoc_files = [
      "LICENSE.txt",
      "README.md"
  ]
  spec.require_paths = ["lib"]

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_runtime_dependency(%q<optimist>, ["~> 3.0.0"])
  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry', '>=0'
  spec.add_development_dependency 'simplecov', '>=0'
  spec.add_development_dependency 'fakefs', '>=0'
  spec.add_development_dependency 'rubocop'
end


