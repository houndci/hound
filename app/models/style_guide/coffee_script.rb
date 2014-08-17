# Determine CoffeeScript style guide violations per-line.
module StyleGuide
  class CoffeeScript
    CONFIG_FILE = ".hound/coffee.json"

    def initialize(pull_request)
      @pull_request = pull_request
    end

    def violations(file)
      violations_per_line(file).map do |line_number, violations|
        if modified_line = file.modified_line_at(line_number)
          messages = violations.map { |violation| violation["message"] }.uniq
          Violation.new(file.filename, modified_line, messages)
        end
      end.compact
    end

    private

    def violations_per_line(file)
      Coffeelint.lint(file.content, config).
        group_by { |violation| violation["lineNumber"] }
    end

    def config
      hound_config.merge(pull_request_config)
    end

    def hound_config
      JSON.parse(File.read("config/coffeelint.json"))
    end

    def pull_request_config
      JSON.parse(config_chain)
    end

    def config_chain
      @pull_request.config_for(CONFIG_FILE) || "{}"
    end
  end
end
