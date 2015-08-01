module StyleGuide
  class Base
    pattr_initialize :repo_config, :repository_owner_name
    attr_implement :file_review

    def file_review(commit_file)
      attributes = build_attributes(commit_file)
      job_class.perform_later(attributes)
      FileReview.new(filename: commit_file.filename)
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

    def name
      self.class.name.demodulize.underscore
    end

    def language
      self.class::LANGUAGE
    end

    def job_class
      "#{language.capitalize}ReviewJob".constantize
    end

    def build_attributes(commit_file)
      {
        filename: commit_file.filename,
        commit_sha: commit_file.sha,
        pull_request_number: commit_file.pull_request_number,
        patch: commit_file.patch,
        content: commit_file.content,
        config: repo_config.raw_for(language),
      }
    end
  end
end
