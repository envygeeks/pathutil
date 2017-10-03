# Frozen-string-literal: true
# Copyright: 2015 - 2017 Jordon Bedwell - MIT License
# Encoding: utf-8

require "support/coverage"
require "luna/rspec/formatters/checks"
require "rspec/helpers"
require "pathutil"

Dir[File.expand_path("../../support/**/*.rb", __FILE__)].each do |f|
  require f
end
