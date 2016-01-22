# Returns empty set of violations.
module Linter
  class Unsupported < Base
    class CannotReviewUnsupportedFile < StandardError; end

    def self.can_lint?(*)
      true
    end

    def file_review(commit_file)
      raise CannotReviewUnsupportedFile.new(commit_file.filename)
    end

    def file_included?(*)
      false
    end
  end
end
