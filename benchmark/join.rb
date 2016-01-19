# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015-2016 Jordon Bedwell - MIT License
# Encoding: utf-8
# ----------------------------------------------------------------------------

require "bundler/setup"
require "benchmark/ips"
require "pathutil"

Benchmark.ips :quiet => true do |x|
  x.json! "benchmark.json"
  x.report("A:Pathname#join") { Pathname.new("/tmp").join("/1") }
  x.report("B:Pathutil#join") { Pathutil.new("/tmp").join("/1") }
  x.compare!
end
