# Base to contain common style guide logic
module StyleGuide
  CONFIG_DIR = "config/style_guides"

  class Base
    pattr_initialize :repo_config

    def enabled?
      repo_config.enabled_for?(name)
    end

    def violations_in_file(_file)
      raise NotImplementedError.new("must implement ##{__method__}")
    end

    private

    def name
      self.class.name.demodulize.underscore
    end
  end
end
