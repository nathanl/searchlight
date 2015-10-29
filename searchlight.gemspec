# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'searchlight/version'

Gem::Specification.new do |spec|
  spec.license       = 'MIT'
  spec.name          = "searchlight"
  spec.version       = Searchlight::VERSION
  spec.authors       = ["Nathan Long", "Adam Hunter"]
  spec.email         = ["nathanmlong@gmail.com", "adamhunter@me.com"]
  spec.summary        = %q{Searchlight is a low-magic way to build database searches using an ORM.}
  spec.description    = %q{Searchlight is a low-magic way to build database searches using an ORM. It's compatible with ActiveRecord, Sequel, Mongoid, and any other ORM that can build queries by chaining method calls.}
  spec.homepage      = "https://github.com/nathanl/searchlight"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec",     "~> 3.2"
  spec.add_development_dependency "bundler",   "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "capybara",  "~> 2.4"

  # To test integration with actionview and activerecord
  spec.add_development_dependency "actionview",         "~> 4.1"
  spec.add_development_dependency "activemodel",        "~> 4.1"
end
