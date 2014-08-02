# Determine Ruby style guide violations per-line.
module StyleGuide
  class Ruby < Base
    DEFAULT_CONFIG_FILE = File.join(CONFIG_DIR, "ruby.yml")

    private

    def excluded_file?(file)
      config.file_to_exclude?(file.filename)
    end

    def uniq_messages_from_violations(violations)
      violations.map(&:message).uniq
    end

    def violations_per_line(file)
      team.inspect_file(parsed_source(file)).group_by(&:line)
    end

    def team
      RuboCop::Cop::Team.new(RuboCop::Cop::Cop.all, config, rubocop_options)
    end

    def parsed_source(file)
      RuboCop::ProcessedSource.new(file.content)
    end

    def config
      @config ||= RuboCop::Config.new(merged_config, "")
    end

    def merged_config
      RuboCop::ConfigLoader.merge(default_config, custom_config)
    rescue TypeError
      default_config
    end

    def default_config
      RuboCop::ConfigLoader.configuration_from_file(DEFAULT_CONFIG_FILE)
    end

    def custom_config
      RuboCop::Config.new(repo_config.for(name), "").tap do |config|
        config.add_missing_namespaces
        config.make_excludes_absolute
      end
    rescue NoMethodError
      RuboCop::Config.new
    end

    def rubocop_options
      if config["ShowCopNames"]
        { debug: true }
      end
    end
  end
end
