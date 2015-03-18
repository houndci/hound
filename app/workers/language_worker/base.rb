module LanguageWorker
  class Base
    pattr_initialize :build_worker,
                     :pull_request_file,
                     :repo_config,
                     :pull_request

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
  end
end
