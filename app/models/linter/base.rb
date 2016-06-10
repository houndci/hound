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
        linter_name: name,
      )

      enqueue_job(attributes)

      file_review
    end

    def enabled?
      CheckEnabledLinter.run(config)
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
        config: merged_config,
        content: commit_file.content,
        filename: commit_file.filename,
        linter_name: name,
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

    def merged_config
      owner_config.merge(config)
    end

    def owner_config
      @owner_config ||= ConfigBuilder.for(owner_hound_config, name)
    end

    def owner_hound_config
      BuildOwnerHoundConfig.run(build.repo, hound_config)
    end

    def config
      @config ||= ConfigBuilder.for(hound_config, name)
    end
  end
end
