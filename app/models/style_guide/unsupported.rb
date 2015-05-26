# Returns empty set of violations.
module StyleGuide
  class Unsupported < Base
    def file_review(file)
      FileReview.new(filename: file.filename)
    end
  end
end
