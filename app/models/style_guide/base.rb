module StyleGuide
  class Base
    def violations_in_file(_file)
      raise NotImplementedError.new("must implement ##{__method__}")
    end
  end
end
