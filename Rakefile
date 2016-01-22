# Frozen-string-literal: true
# Copyright: 2015-2016 Jordon Bedwell - MIT License
# Encoding: utf-8

require "open3"
require "rspec/core/rake_task"
require_relative "benchmark/support/task"
require "simple/ansi"
require "pathutil"
require "json"

task :default => [:spec]
RSpec::Core::RakeTask.new :spec
BenchmarkTask.new :benchmark
task :test => :spec

# ----------------------------------------------------------------------------

namespace :diff do
  desc "List methods we have that Pathname doesn't."
  task :methods do
    methods = Pathutil.instance_methods - Pathname.instance_methods - Object.instance_methods
    methods.each do |method|
      $stdout.print "- ", "`", method, "`", "\n"
    end
  end
end

# ----------------------------------------------------------------------------

namespace :missing do
  desc "List methods we are missing."
  task :methods do
    methods = Pathname.instance_methods - Pathutil.instance_methods - Object.instance_methods
    methods-= [
      :cleanpath
    ]

    methods.each do |method|
      $stdout.puts method
    end
  end
end

# ----------------------------------------------------------------------------

namespace :pathname do
  desc "List all of Pathnames methods."
  task :methods do
    methods = Pathname.instance_methods - Object.instance_methods
    methods.each_with_index do |method, index|
      $stdout.print method
      unless index == methods.size - 1
        $stdout.print ", "
      end
    end

    $stdout.puts
  end
end

# ----------------------------------------------------------------------------

desc "List all of Pathutils methods."
task :methods do
  methods = Pathutil.instance_methods - Object.instance_methods
  methods.each_with_index do |method, index|
    $stdout.print "`", method, "`"
    $stdout.print ", " unless index == methods.size - 1
  end

  $stdout.puts
end

# ----------------------------------------------------------------------------

task :rubocop do
  sh "bundle", "exec", "rubocop", "-DE", "-r", "luna/rubocop/formatters/checks", \
    "-f", "Luna::RuboCop::Formatters::Checks"
end
