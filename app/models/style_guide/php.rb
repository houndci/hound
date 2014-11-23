module StyleGuide
  class PHP < Base
    def violations_in_file(file)
      Phpcs::Phpcs.new(config).lint(file.content).map do |violation|
        Violation.new(file, violation.line, violation.comment)
      end
    end

    private

    def config
      repo_conf = repo_config.for(name)
      repo_conf == {} ? default_config : repo_conf || default_config
    end

    def default_config
      "PSR2"
    end
  end
end
