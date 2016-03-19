# ----------------------------------------------------------------------------
# Frozen-string-literal: true
# Copyright: 2015-2016 Jordon Bedwell - MIT License
# Encoding: utf-8
# ----------------------------------------------------------------------------

RSpec::Matchers.define :have_method do |method|
  match do |owner|
    owner.method_defined?(method)
  end
end
