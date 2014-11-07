module StyleGuide
  class JavaScript < Base
    DEFAULT_CONFIG_FILENAME = "javascript.json"

    def violations_in_file(file)
      Jshintrb.lint(file.content, config).compact.map do |violation|
        line = file.line_at(violation["line"])

        Violation.new(
          filename: file.filename,
          patch_position: line.patch_position,
          line: line,
          line_number: violation["line"],
          messages: [violation["reason"]]
        )
      end
    end

    def file_included?(file)
      !excluded_files.any? { |pattern| File.fnmatch?(pattern, file.filename) }
    end

    private

    def config
      custom_config = repo_config.for(name)
      if custom_config["predef"].present?
        custom_config["predef"] |= default_config["predef"]
      end
      default_config.merge(custom_config)
    end

    def excluded_files
      repo_config.ignored_javascript_files
    end

    def default_config
      config_file = File.read(default_config_file)
      JSON.parse(config_file)
    end

    def default_config_file
      DefaultConfigFile.new(DEFAULT_CONFIG_FILENAME, repository_owner).path
    end
  end
end
