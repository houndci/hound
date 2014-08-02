# Determine CoffeeScript style guide violations per-line.
module StyleGuide
  class CoffeeScript < Base
    DEFAULT_CONFIG_FILE = File.join(CONFIG_DIR, "coffeescript.json")

    private

    def excluded_file?(_file)
      false
    end

    def uniq_messages_from_violations(violations)
      violations.map { |violation| violation["message"] }.uniq
    end

    def violations_per_line(file)
      Coffeelint.lint(file.content, config).
        group_by { |violation| violation["lineNumber"] }
    end

    def config
      default_config.merge(repo_config.for(name))
    end

    def default_config
      JSON.parse(File.read(DEFAULT_CONFIG_FILE))
    end
  end
end
