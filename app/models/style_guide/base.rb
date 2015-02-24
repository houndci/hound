# Base to contain common style guide logic
module StyleGuide
  class Base
    pattr_initialize :repo_config, :repository_owner_name

    def enabled?
      repo_config.enabled_for?(name)
    end

    attr_implement :violations_in_file

    def file_included?(_file)
      true
    end

    private

    def name
      self.class.name.demodulize.underscore
    end
  end
end
