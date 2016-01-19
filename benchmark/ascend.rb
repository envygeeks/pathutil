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
  x.report("A:Pathname#ascend") { Pathname.new("/tmp").ascend.to_a }
  x.report("B:Pathutil#ascend") { Pathutil.new("/tmp").ascend.to_a }
  x.compare!
end
