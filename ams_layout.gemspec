# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ams_layout/version'

Gem::Specification.new do |spec|
  spec.name          = "ams_layout"
  spec.version       = AmsLayout::VERSION
  spec.authors       = ["Jeff McAffee"]
  spec.email         = ["jeff@ktechsystems.com"]
  spec.summary       = %q{Generate AMS Portal control field configuration data}
  spec.description   = %q{Generate AMS Portal control field configuration data}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry", "~> 0.10"
  #spec.add_development_dependency "pry-byebug", "~> 1.3.1"

  spec.add_runtime_dependency 'ktutils'
  spec.add_runtime_dependency 'page-object'
  spec.add_runtime_dependency 'nokogiri'
end
