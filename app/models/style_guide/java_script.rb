module StyleGuide
  class JavaScript < Base
    DEFAULT_CONFIG_FILE = File.join(CONFIG_DIR, "javascript.json")

    def violations_in_file(file)
      Jshintrb.lint(file.content, config).compact.map do |violation|
        Violation.new(file, violation["line"], violation["reason"])
      end
    end

    private

    def config
      custom_config = repo_config.for(name)
      if custom_config["predef"].present?
        custom_config["predef"] |= default_config["predef"]
      end
      default_config.merge(custom_config)
    end

    def default_config
      JSON.parse(File.read(DEFAULT_CONFIG_FILE))
    end
  end
end
