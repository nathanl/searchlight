# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pilfer/version'

Gem::Specification.new do |spec|
  spec.name          = "pilfer"
  spec.version       = Pilfer::VERSION
  spec.authors       = ["Nathan Long", "Adam Hunter"]
  spec.email         = ["nathanmlong@gmail.com", "adamhunter@me.com"]
  spec.description   = %q{Pilfer helps you build searches from options via Ruby methods that you write. It's like Ransack, but less so.}
  spec.summary       = %q{Pilfer helps you build searches from options via Ruby methods that you write. It's like Ransack, but less so.}
  spec.homepage      = "https://github.com/nathanl/pilfer"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "named", "~> 1.0"

  spec.add_development_dependency "rspec",     "~> 2.13"
  spec.add_development_dependency "bundler",   "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rails",     ">= 3"
  spec.add_development_dependency "capybara",  "~> 2.0"
end
