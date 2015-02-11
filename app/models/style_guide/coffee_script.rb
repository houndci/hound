module StyleGuide
  class CoffeeScript < Base
    BASE_CONFIG_FILE = "config/style_guides/coffeescript.json"
    CONFIG_FILE = ".coffeescript-style.json"

    attr_reader :custom_config

    def initialize(config = "{}")
      @custom_config = JSON.parse(config)
    end

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
      base_config.merge(custom_config)
    end

    def base_config
      JSON.parse(File.read(BASE_CONFIG_FILE))
    end
  end
end
