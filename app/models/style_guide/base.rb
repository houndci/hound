# Base to contain common style guide logic
module StyleGuide
  class Base
    # necessary?
    def enabled?
      repo_config.enabled_for?(name)
    end

    def violations_in_file(_file)
      raise NotImplementedError.new("must implement ##{__method__}")
    end

    def file_included?(_file)
      true
    end

    private

    def name
      self.class.name.demodulize.underscore
    end
  end
end
