# Returns empty set of violations.
module StyleGuide
  class Unsupported < Base
    class CannotReviewUnsupportedFile < StandardError; end

    def file_review(commit_file)
      raise CannotReviewUnsupportedFile.new(commit_file.filename)
    end

    def file_included?(*)
      false
    end
  end
end
