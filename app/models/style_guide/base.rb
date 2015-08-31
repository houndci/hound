module StyleGuide
  class Base
    attr_implement :file_review

    def initialize(repo_config:, build:, repository_owner_name:)
      @repo_config = repo_config
      @build = build
      @repository_owner_name = repository_owner_name
    end

    def file_review(commit_file)
      attributes = build_review_job_attributes(commit_file)
      file_review = FileReview.create!(
        build: build,
        filename: commit_file.filename,
      )

      Resque.enqueue(job_class, attributes)

      file_review
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

    def build_review_job_attributes(commit_file)
      {
        filename: commit_file.filename,
        commit_sha: commit_file.sha,
        pull_request_number: commit_file.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: repo_config.raw_for(language),
      }
    end

    def job_class
      "#{language.capitalize}ReviewJob".constantize
    end

    def language
      self.class::LANGUAGE
    end

    def name
      self.class.name.demodulize.underscore
    end
  end
end
