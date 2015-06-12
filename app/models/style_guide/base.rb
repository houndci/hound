module StyleGuide
  class Base
    pattr_initialize :repo_config, :repository_owner_name
    attr_implement :file_review

    def enabled?
      repo_config.enabled_for?(name)
    end

    def file_included?(*)
      raise StandardError.new(
        "Implement #file_included? in your StyleGuide class"
      )
    end

    private

    def name
      self.class.name.demodulize.underscore
    end
  end
end
