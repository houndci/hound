# Determine CoffeeScript style guide violations per-line.
module StyleGuide
  class CoffeeScript
    DEFAULT_CONFIG_FILE = "config/style_guides/coffeescript.json"

    def violations(file)
      violations_on_modified_lines(file).map do |line_number, violations|
        modified_line = file.modified_line_at(line_number)
        messages = violations.map { |violation| violation["message"] }.uniq
        Violation.new(file.filename, modified_line, messages)
      end
    end

    private

    def violations_on_modified_lines(file)
      violations_per_line(file).select do |line_number, _|
        file.modified_line_at(line_number)
      end
    end

    def violations_per_line(file)
      Coffeelint.lint(file.content, config).
        group_by { |violation| violation["lineNumber"] }
    end

    def config
      JSON.parse(File.read(DEFAULT_CONFIG_FILE))
    end
  end
end
