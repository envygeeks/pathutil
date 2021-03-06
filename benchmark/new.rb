# Frozen-string-literal: true
# Copyright: 2015 - 2017 Jordon Bedwell - MIT License
# Encoding: utf-8

require "bundler/setup"
require "benchmark/ips"
require "pathutil"

Benchmark.ips :quiet => true do |x|
  x.json! "benchmark.json"
  x.report("A:Pathname#new") { Pathname.new("/tmp") }
  x.report("B:Pathutil#new") { Pathutil.new("/tmp") }
  x.compare!
end
