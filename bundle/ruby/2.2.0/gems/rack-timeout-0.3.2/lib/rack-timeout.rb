require_relative "rack/timeout/base"
require_relative "rack/timeout/rails" if defined?(Rails) && [3,4].include?(Rails::VERSION::MAJOR)
