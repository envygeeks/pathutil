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
  x.report("A:Pathname#read") { Pathname.new("~/.bashrc").expand_path.read }
  x.report("B:Pathutil#read") { Pathutil.new("~/.bashrc").expand_path.read }
  x.compare!
end
