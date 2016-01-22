RSpec.configure do |c|
  if Gem::Version.new(RUBY_VERSION).segments.values_at(0, 1) == [2, 0]
    c.filter_run_excluding({
      :disable => :oldest_ruby
    })
  end
end
