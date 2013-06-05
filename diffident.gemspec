# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'diffident/version'

Gem::Specification.new do |spec|
  spec.name          = "diffident"
  spec.version       = Diffident::VERSION
  spec.authors       = ["Jonas Schubert Erlandsson", "Pieter van de Bruggen"]
  spec.email         = "jonas.schubert.erlandsson@my-codeworks.com"
  spec.summary       = "A pure ruby implementation for generating and merging string diffs"
  spec.description   = "diffident: To show modest reserve, a gem to create and manipulate text diffs. This gem provides a pure ruby implementation of a diff tool. It gives access to several methods by which to get a diff from strings and ways to format the output. It also gives direct access to the internal diff structure so that you can manipulate and extend it any way you need to."
  spec.homepage      = "http://github.com/my-codeworks/diffident"
  spec.license       = "MIT"

  spec.files         = Dir.glob("lib/**/*") + %w(LICENSE README.md CHANGELOG.md)
  spec.test_files    = Dir.glob("spec/**/*")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
end