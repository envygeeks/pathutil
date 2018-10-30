require "bundler/setup"

require "open3"
require "rspec/core/rake_task"
require_relative "../../benchmark/support/task"
require "rubocop/rake_task"
require "simple/ansi"
require "pathutil"
require "json"

# --

task :default => [
  ENV["BENCHMARK"] ? :benchmark : :spec
]

# --

BenchmarkTask.new :benchmark
RSpec::Core::RakeTask.new :spec
task :test => :spec
