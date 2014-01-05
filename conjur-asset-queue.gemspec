# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'conjur-asset-queue-version'

Gem::Specification.new do |spec|
  spec.name          = "conjur-asset-queue"
  spec.version       = Conjur::Asset::Queue::VERSION
  spec.authors       = ["Kevin Gilpin"]
  spec.email         = ["kgilpin@conjur.net"]
  spec.homepage      = "http://conjur.net"
  spec.summary       = "Conjur asset plugin for a secure queue."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "conjur-api"
  spec.add_dependency "conjur-asset-key-pair-api"

  spec.add_development_dependency "conjur-cli"
  spec.add_development_dependency "conjur-asset-environment-api"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "aws-sdk"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "spork"
  spec.add_development_dependency "webmock"
end
