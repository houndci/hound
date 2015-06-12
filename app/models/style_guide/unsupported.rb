# Returns empty set of violations.
module StyleGuide
  class Unsupported < Base
    class CannotReviewUnsupportedFile < StandardError; end

    def file_review(file)
      raise CannotReviewUnsupportedFile.new(file.filename)
    end

    def file_included?(*)
      false
    end
  end
end
