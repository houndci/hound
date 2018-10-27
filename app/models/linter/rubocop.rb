module Linter
  class Rubocop < Base
    FILE_REGEXP = /.+(\.rb|\.rake|\.jbuilder)|(Gemfile|Rakefile)\z/

    private

    def job_class
      LintersJob
    end
  end
end
