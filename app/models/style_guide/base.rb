# Base to contain common style guide logic
module StyleGuide
  class Base
    pattr_initialize :repo_config, :repository_owner_name
    attr_implement :file_review

    def enabled?
      repo_config.enabled_for?(name)
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
