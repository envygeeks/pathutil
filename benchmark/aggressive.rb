# Frozen-string-literal: true
# Copyright: 2015-2016 Jordon Bedwell - MIT License
# Encoding: utf-8

require "bundler/setup"
require "benchmark/ips"
require "pathutil"

Benchmark.ips :quiet => true do |x|
  x.json! "benchmark.json"
  x.report("A:Pathname#cleanpath_aggressive") { Pathname.new("world/../../../////..//./hello/world////../../../").send(:cleanpath_aggressive) }
  x.report("B:Pathutil#cleanpath_aggressive") { Pathutil.new("world/../../../////..//./hello/world////../../../").send(:cleanpath_aggressive) }
  x.compare!
end
