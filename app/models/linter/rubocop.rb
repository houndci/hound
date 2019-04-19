module Linter
  class Rubocop < Base
    FILE_REGEXP = /.+(\.rb|\.rake|\.jbuilder)|(Gemfile|Rakefile|Podfile)\z/
  end
end
