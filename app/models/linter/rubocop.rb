module Linter
  class Rubocop < Base
    FILE_REGEXP = /.+(\.rb|\.rake|\.jbuilder)|(Gemfile|Rakefile)\z/
  end
end
