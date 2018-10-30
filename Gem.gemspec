# Frozen-string-literal: true
# Copyright: 2015 - 2017 Jordon Bedwell - MIT License
# Encoding: utf-8

$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
require "pathutil/version"

Gem::Specification.new do |spec|
  spec.authors = ["Jordon Bedwell"]
  spec.version = Pathutil::VERSION
  spec.files = %W(Rakefile Gemfile LICENSE) + Dir["{lib,bin}/**/*"]
  spec.description = "Like Pathname but a little less insane."
  spec.summary = "Almost like Pathname but just a little less insane."
  spec.homepage = "http://github.com/envygeeks/pathutil"
  spec.email = ["jordon@envygeeks.io"]
  spec.require_paths = ["lib"]
  spec.name = "pathutil"
  spec.license = "MIT"
  spec.bindir = "bin"

  spec.add_runtime_dependency "forwardable-extended", "~> 2.6"
end
