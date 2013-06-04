# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'diffident/version'

Gem::Specification.new do |spec|
  spec.name          = "Diffident"
  spec.version       = Diffident::VERSION
  spec.authors       = ["Pieter van de Bruggen", "Jonas Schubert Erlandsson"]
  spec.date          = %q{2011-02-17}
  spec.email         = ["pvande@gmail.com", "jonas.schubert.erlandsson@my-codeworks.com"]
  spec.description   = "A simple gem for generating string diffs"
  spec.summary       = "A simple gem for generating string diffs"
  spec.homepage      = "http://github.com/pvande/Diffident"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end