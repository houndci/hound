# Determine CoffeeScript style guide violations per-line.
module StyleGuide
  class CoffeeScript < Base
    DEFAULT_CONFIG_FILENAME = "coffeescript.json"
    ERB_TAGS = /<%.*%>/

    def violations_in_file(file)
      content = content_for_file(file)
      lint(content).map do |violation|
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

    def lint(content)
      Coffeelint.lint(content, config)
    end

    def content_for_file(file)
      if erb? file
        file.content.gsub(ERB_TAGS, "123")
      else
        file.content
      end
    end

    def erb?(file)
      file.filename.ends_with? ".erb"
    end

    def config
      default_config.merge(repo_config.for(name))
    end

    def default_config
      config = File.read(default_config_file)
      JSON.parse(config)
    end

    def default_config_file
      DefaultConfigFile.new(
        DEFAULT_CONFIG_FILENAME,
        repository_owner_name
      ).path
    end

    def name
      "coffeescript"
    end
  end
end
