# Determine CoffeeScript style guide violations per-line.
module StyleGuide
  class CoffeeScript < Base
    DEFAULT_CONFIG_FILE = File.join(CONFIG_DIR, "coffeescript.json")

    def violations_in_file(file)
      Coffeelint.lint(file.content, config).map do |violation|
        Violation.new(file, violation["lineNumber"], violation["message"])
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
