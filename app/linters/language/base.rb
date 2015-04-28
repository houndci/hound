module Language
  class Base
    pattr_initialize \
      :build_worker,
      :pull_request_file,
      :repo_config,
      :repository_owner_name

    delegate :content, :filename, :patch_body, to: :pull_request_file
    delegate :build, to: :build_worker

    attr_implement :run

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

    def callback_url
      "#{ENV.fetch("BUILD_WORKER_CALLBACK_URL")}/#{build_worker.id}"
    end
  end
end
