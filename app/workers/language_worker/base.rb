module LanguageWorker
  class Base
    pattr_initialize :build_worker, :commit_file, :repo_config, :pull_request

    delegate :content, :patch, :filename, to: :commit_file
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
