# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cfoo/version'

Gem::Specification.new do |gem|
  gem.name          = "cfoo"
  gem.version       = Cfoo::VERSION
  gem.authors       = ["drrb"]
  gem.email         = ["drrrrrrrrrrrb@gmail.com"]
  gem.description   = "Cfoo: CloudFormation master"
  gem.summary       = <<-EOF
    Cfoo (pronounced 'sifu') allows you to write your CloudFormation templates in a
    YAML-based markup language, and organise it into modules to make it easier to
    maintain.
  EOF
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end