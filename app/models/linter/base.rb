module Linter
  class Base
    def self.can_lint?(filename)
      self::FILE_REGEXP === filename
    end

    def initialize(hound_config:, build:, repository_owner_name:)
      @hound_config = hound_config
      @build = build
      @repository_owner_name = repository_owner_name
    end

    def file_review(commit_file)
      attributes = build_review_job_attributes(commit_file)
      file_review = FileReview.create!(
        build: build,
        filename: commit_file.filename,
      )

      enqueue_job(attributes)

      file_review
    end

    def enabled?
      hound_config.enabled_for?(name)
    end

    def file_included?(*)
      true
    end

    def name
      self.class.name.demodulize.underscore
    end

    private

    attr_reader :hound_config, :build, :repository_owner_name

    def build_review_job_attributes(commit_file)
      {
        commit_sha: build.commit_sha,
        config: config.content,
        content: commit_file.content,
        filename: commit_file.filename,
        patch: commit_file.patch,
        pull_request_number: build.pull_request_number,
      }
    end

    def enqueue_job(attributes)
      Resque.enqueue(job_class, attributes)
    end

    def job_class
      "#{name.classify}ReviewJob".constantize
    end

    def config
      @config ||= config_class.new(hound_config, name)
    end

    def config_class
      "Config::#{name.classify}".constantize
    end
  end
end
