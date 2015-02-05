# Returns empty set of violations.
module StyleGuide
  class Unsupported < Base
    CONFIG_FILE = ""

    pattr_initialize :config

    def violations_in_file(_)
      []
    end
  end
end
