# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hookit/version'

Gem::Specification.new do |spec|
  spec.name          = "hookit"
  spec.version       = Hookit::VERSION
  spec.authors       = ["Tyler Flint", "Greg Linton"]
  spec.email         = ["tyler@pagodabox.com"]
  spec.summary       = %q{Hookit is a framework to provide hookit scripts with re-usable components and resources via an elegant dsl.}
  spec.description   = %q{The core framework to provide hookit scripts with re-usable components.}
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
  spec.add_dependency 'excon'
  spec.add_dependency 'faraday'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
