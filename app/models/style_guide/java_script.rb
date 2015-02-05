module StyleGuide
  class JavaScript < Base
    BASE_CONFIG_FILE = "config/style_guides/javascript.json"
    CONFIG_FILE = ".javascript-style.json"

    attr_reader :custom_config, :excluded_files

    def initialize(config = "{}")
      @custom_config = JSON.parse(config)
      @excluded_files = @custom_config.delete("exclude") || []
    end

    def violations_in_file(file)
      if include?(file)
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
      else
        []
      end
    end

    private

    def include?(file)
      excluded_files.none? do |pattern|
        File.fnmatch?(pattern, file.filename)
      end
    end

    def config
      base_config.merge(custom_config)
    end

    def base_config
      JSON.parse(File.read(BASE_CONFIG_FILE))
    end
  end
end
