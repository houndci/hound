module StyleGuide
  class JavaScript < Base
    DEFAULT_CONFIG_FILE = File.join(CONFIG_DIR, "javascript.json")

    def violations_in_file(file)
      Jshintrb.lint(file.content, config).map do |violation|
        Violation.new(file, violation["line"], violation["reason"])
      end
    end

    private

    def config
      default_config.merge(repo_config.for(name))
    end

    def default_config
      JSON.parse(File.read(DEFAULT_CONFIG_FILE))
    end
  end
end
