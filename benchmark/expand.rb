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
  x.report("A:Pathname#expand_path") { Pathname.new("~/.bashrc").expand_path }
  x.report("B:Pathutil#expand_path") { Pathutil.new("~/.bashrc").expand_path }
  x.compare!
end
