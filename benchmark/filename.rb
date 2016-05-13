# Frozen-string-literal: true
# Copyright: 2015-2016 Jordon Bedwell - MIT License
# Encoding: utf-8

require "bundler/setup"
require "benchmark/ips"
require "pathutil"

Benchmark.ips :quiet => true do |x|
  x.json! "benchmark.json"
  x.report("A:Pathname#each_filename") { Pathname.new("/tmp").each_filename }
  x.report("B:Pathutil#each_filename") { Pathutil.new("/tmp").each_filename }
  x.compare!
end
