# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cfml/version'

Gem::Specification.new do |gem|
  gem.name          = "cfml"
  gem.version       = Cfml::VERSION
  gem.authors       = ["drrb"]
  gem.email         = ["drrrrrrrrrrrb@gmail.com"]
  gem.description   = "CloudFormation Markup Language"
  gem.summary       = <<-EOF
    Write your CloudFormation templates in a YAML-based markup language
  EOF
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
