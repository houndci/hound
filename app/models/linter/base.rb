module Linter
  class Base
    def self.can_lint?(filename)
      self::FILE_REGEXP === filename
    end

    def initialize(hound_config:, build:)
      @hound_config = hound_config
      @build = build
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
      hound_config.linter_enabled?(name)
    end

    def file_included?(*)
      true
    end

    def name
      self.class.name.demodulize.underscore
    end

    private

    attr_reader :hound_config, :build

    def build_review_job_attributes(commit_file)
      {
        commit_sha: build.commit_sha,
        config: config.serialize,
        content: commit_file.content,
        filename: commit_file.filename,
        linter_name: name,
        patch: commit_file.patch,
        pull_request_number: build.pull_request_number,
      }.tap do |attributes|
        if version.present?
          attributes[:linter_version] = version
        end
      end
    end

    def enqueue_job(attributes)
      Resque.enqueue(job_class, attributes)
    end

    def job_name
      "#{name.classify}ReviewJob"
    end

    def job_class
      job_name.constantize
    end

    def owner
      build.repo.owner || MissingOwner.new
    end

    def config
      @_config ||= BuildConfig.call(
        hound_config: hound_config,
        name: name,
        owner: owner,
      )
    end

    def version
      hound_config.linter_version(name)
    end
  end
end
