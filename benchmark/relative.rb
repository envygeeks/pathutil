# Frozen-string-literal: true
# Copyright: 2015 - 2017 Jordon Bedwell - MIT License
# Encoding: utf-8

require "bundler/setup"
require "benchmark/ips"
require "pathutil"

Benchmark.ips :quiet => true do |x|
  x.json! "benchmark.json"
  x.report("A:Pathname#relative_path_from") { Pathname.new("/tmp").relative_path_from Pathname.new("/") }
  x.report("B:Pathutil#relative_path_from") { Pathutil.new("/tmp").relative_path_from "/" }
  x.compare!
end
