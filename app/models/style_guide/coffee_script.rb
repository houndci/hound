# Determine CoffeeScript style guide violations per-line.
module StyleGuide
  class CoffeeScript < Base
    DEFAULT_CONFIG_FILENAME = "coffeescript.json"

    def violations_in_file(file)
      Coffeelint.lint(file.content, config).map do |violation|
        line = file.line_at(violation["lineNumber"])

        Violation.new(
          filename: file.filename,
          line: line,
          patch_position: line.patch_position,
          line_number: violation["lineNumber"],
          messages: [violation["message"]]
        )
      end
    end

    private

    def config
      default_config.merge(repo_config.for(name))
    end

    def default_config
      config = File.read(default_config_file)
      JSON.parse(config)
    end

    def default_config_file
      DefaultConfigFile.new(DEFAULT_CONFIG_FILENAME, repository_owner).path
    end
  end
end
