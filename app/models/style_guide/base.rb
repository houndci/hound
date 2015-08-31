module StyleGuide
  class Base
    attr_implement :file_review

    def initialize(repo_config:, build:, repository_owner_name:)
      @repo_config = repo_config
      @build = build
      @repository_owner_name = repository_owner_name
    end

    def enabled?
      repo_config.enabled_for?(name)
    end

    def file_included?(*)
      raise StandardError.new(
        "Implement #file_included? in your StyleGuide class"
      )
    end

    private

    attr_reader :repo_config, :build, :repository_owner_name

    def name
      self.class.name.demodulize.underscore
    end
  end
end
