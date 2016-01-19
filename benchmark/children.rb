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
  x.report("A:Pathname#children") { Pathname.new("/tmp").children }
  x.report("B:Pathutil#children") { Pathutil.new("/tmp").children }
  x.compare!
end
