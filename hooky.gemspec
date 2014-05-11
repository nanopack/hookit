# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hooky/version'

Gem::Specification.new do |spec|
  spec.name          = "hooky"
  spec.version       = Hooky::VERSION
  spec.authors       = ["Tyler Flint"]
  spec.email         = ["tyler@pagodabox.com"]
  spec.summary       = %q{Hooky is the framework to provide hooky scripts with re-usable components and resources via an elegant dsl.}
  spec.description   = %q{The core framework to provide hooky scripts with re-usable components.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'tilt'
  spec.add_dependency 'erubis'
  spec.add_dependency 'oj'
  spec.add_dependency 'multi_json', '>= 1.3'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
