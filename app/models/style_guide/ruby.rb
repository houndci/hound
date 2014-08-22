# Determine Ruby style guide violations per-line.
module StyleGuide
  class Ruby
    CONFIG_FILE = ".hound/ruby.yml"
    LEGACY_CONFIG_FILE = ".hound.yml"

    def initialize(pull_request)
      @pull_request = pull_request
    end

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
      RuboCop::Config.new(
        RuboCop::ConfigLoader.merge(hound_config, pull_request_config),
        ""
      )
    end

    def rubocop_options
      if config["ShowCopNames"]
        { debug: true }
      end
    end

    def hound_config
      RuboCop::ConfigLoader.configuration_from_file(CONFIG_FILE)
    end

    def pull_request_config
      RuboCop::Config.new(config_content, "").tap do |config|
        config.add_missing_namespaces
        config.make_excludes_absolute
      end
    end

    def config_content
      YAML.load(config_chain)
    end

    def config_chain
      @pull_request.config_for(CONFIG_FILE) ||
        @pull_request.config_for(LEGACY_CONFIG_FILE) ||
        "{}"
    end
  end
end
