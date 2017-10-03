# Frozen-string-literal: true
# Copyright: 2015 - 2017 Jordon Bedwell - MIT License
# Encoding: utf-8

require "bundler/setup"
require "benchmark/ips"
require "pathutil"

Benchmark.ips :quiet => true do |x|
  x.json! "benchmark.json"
  x.report("A:Pathname#cleanpath_conservative") { Pathname.new("world/../../../////..//./hello/world////../../../").send(:cleanpath_conservative) }
  x.report("B:Pathutil#cleanpath_conservative") { Pathutil.new("world/../../../////..//./hello/world////../../../").send(:cleanpath_conservative) }
  x.compare!
end
