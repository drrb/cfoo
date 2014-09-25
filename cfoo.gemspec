# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cfoo/version'

Gem::Specification.new do |gem|
  gem.name          = "cfoo"
  gem.version       = Cfoo::VERSION
  gem.authors       = ["drrb"]
  gem.email         = ["drrrrrrrrrrrb@gmail.com"]
  gem.license       = "GPL-3"
  gem.description   = "Cfoo: CloudFormation master"
  gem.summary       = <<-EOF
    Cfoo (pronounced 'sifu') allows you to write your CloudFormation templates in a
    YAML-based markup language, and organise it into modules to make it easier to
    maintain.
  EOF
  gem.homepage      = "https://github.com/drrb/cfoo"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "json"
  gem.add_dependency "parslet", "~> 1.5.0"

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "cucumber"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "coveralls", ">= 0.6.3"
  gem.add_development_dependency "rest-client", "< 1.7.0"
  gem.add_development_dependency "mime-types", "< 2" # Needed to support Ruby 1.8

  unless ["1.8.7", "1.9.2"].include? RUBY_VERSION
      gem.add_development_dependency "guard"
      gem.add_development_dependency "guard-rspec"
      gem.add_development_dependency "terminal-notifier-guard"
  end
end
