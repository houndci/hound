# Returns empty set of violations.
module StyleGuide
  class Unsupported < Base
    def violations_in_file(_)
      []
    end
  end
end
