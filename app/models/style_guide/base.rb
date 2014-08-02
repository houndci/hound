# Base to contain common style guide logic
module StyleGuide
  CONFIG_DIR = "config/style_guides"

  class Base
    pattr_initialize :repo_config

    def enabled?
      repo_config.enabled_for?(name)
    end

    def violations_in_file(file)
      if excluded_file?(file)
        []
      else
        violations_on_modified_lines(file).map do |line_number, violations|
          modified_line = file.modified_line_at(line_number)
          messages = uniq_messages_from_violations(violations)
          Violation.new(file.filename, modified_line, messages)
        end
      end
    end

    private

    def name
      self.class.name.demodulize.underscore
    end

    def violations_on_modified_lines(file)
      violations_per_line(file).select do |line_number, _|
        file.modified_line_at(line_number)
      end
    end
  end
end
