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
  x.report("A:Pathname#sub_ext") { Pathname.new("/tmp").sub_ext(".rb") }
  x.report("B:Pathutil#sub_ext") { Pathutil.new("/tmp").sub_ext(".rb") }
  x.compare!
end
