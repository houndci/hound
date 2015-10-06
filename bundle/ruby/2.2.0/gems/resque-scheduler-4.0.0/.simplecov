if ENV['COVERAGE'] && RUBY_PLATFORM !~ /java/
  SimpleCov.start { add_filter '/test/' }
end
