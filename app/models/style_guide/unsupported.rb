# Returns empty set of violations.
module StyleGuide
  class Unsupported < Base
    def enabled?
      false
    end

    def violations(_)
      []
    end
  end
end
