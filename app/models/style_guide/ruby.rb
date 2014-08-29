# Determine Ruby style guide violations per-line.
module StyleGuide
  class Ruby
    pattr_initialize :custom_config

    def violations(file)
      if excluded_file?(file)
        []
      else
        violations_per_line(file).map do |line_number, violations|
          if modified_line = file.modified_line_at(line_number)
            messages = violations.map(&:message).uniq
            Violation.new(file.filename, modified_line, messages)
          end
        end.compact
      end
    end

    private

    def violations_per_line(file)
      team.inspect_file(parsed_source(file)).group_by(&:line)
    end

    def team
      RuboCop::Cop::Team.new(RuboCop::Cop::Cop.all, config, rubocop_options)
    end

    def parsed_source(file)
      RuboCop::ProcessedSource.new(file.content)
    end

    def excluded_file?(file)
      config.file_to_exclude?(file.filename)
    end

    def config
      @config ||= RuboCop::Config.
        new(RuboCop::ConfigLoader.merge(hound_config, pull_request_config), "")
    end

    def rubocop_options
      if config["ShowCopNames"]
        { debug: true }
      end
    end

    def hound_config
      RuboCop::ConfigLoader.configuration_from_file("config/rubocop.yml")
    end

    def pull_request_config
      RuboCop::Config.new(parsed_custom_config, "").tap do |config|
        config.add_missing_namespaces
        config.make_excludes_absolute
      end
    rescue NoMethodError
      RuboCop::Config.new
    end

    def parsed_custom_config
      YAML.load(@custom_config)
    rescue Psych::SyntaxError
      {}
    end
  end
end
