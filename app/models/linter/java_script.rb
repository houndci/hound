module Linter
  class JavaScript < Base
    DEFAULT_CONFIG_FILENAME = "javascript.json"
    FILE_REGEXP = /.+\.js\z/

    def file_review(commit_file)
      FileReview.create!(filename: commit_file.filename) do |file_review|
        Jshintrb.lint(
          commit_file.content,
          linter_config,
        ).compact.each do |violation|
          line = commit_file.line_at(violation["line"])
          file_review.build_violation(line, violation["reason"])
        end

        file_review.build = build
        file_review.complete
      end
    end

    def file_included?(commit_file)
      excluded_files.none? do |pattern|
        File.fnmatch?(pattern, commit_file.filename)
      end
    end

    private

    def linter_config
      custom_config = config.content
      if custom_config["predef"].present?
        custom_config["predef"] |= default_config["predef"]
      end
      default_config.merge(custom_config)
    end

    def excluded_files
      config.excluded_files
    end

    def default_config
      config_file = File.read(default_config_file)
      Config::Parser.json(config_file)
    end

    def default_config_file
      DefaultConfigFile.new(
        DEFAULT_CONFIG_FILENAME,
        repository_owner_name
      ).path
    end
  end
end
