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
  x.report("A:Pathname#root?") { Pathname.new("/tmp").root? }
  x.report("B:Pathutil#root?") { Pathutil.new("/tmp").root? }
  x.compare!
end
