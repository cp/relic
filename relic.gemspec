# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'relic/version'

Gem::Specification.new do |spec|
  spec.name          = "relic"
  spec.version       = Relic::VERSION
  spec.authors       = ["Colby Aley"]
  spec.email         = ["colby@aley.me"]
  spec.summary       = %q{Simple CLI for the New Relic HTTP API.}
  spec.homepage      = "https://github.com/ColbyAley/relic"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "netrc"
  spec.add_runtime_dependency "httparty"
  spec.add_runtime_dependency "terminal-table"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
