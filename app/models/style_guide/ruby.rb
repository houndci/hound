# Determine Ruby style guide violations per-line.
module StyleGuide
  class Ruby < Base
    DEFAULT_CONFIG_FILENAME = "ruby.yml"

    def file_review(file)
      if config.file_to_exclude?(file.filename)
        FileReview.new(filename: file.filename)
      else
        perform_file_review(file)
      end
    end

    private

    def perform_file_review(file)
      FileReview.new(filename: file.filename) do |file_review|
        team.inspect_file(parsed_source(file)).each do |violation|
          line = file.line_at(violation.line)
          file_review.build_violation(line, violation.message)
        end
        file_review.complete
      end
    end

    def team
      RuboCop::Cop::Team.new(RuboCop::Cop::Cop.all, config, rubocop_options)
    end

    def parsed_source(file)
      absolute_filepath = File.expand_path(file.filename)
      RuboCop::ProcessedSource.new(file.content, absolute_filepath)
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
      RuboCop::ConfigLoader.configuration_from_file(default_config_file)
    end

    def custom_config
      RuboCop::Config.new(repo_config.for(name), "").tap do |config|
        config.add_missing_namespaces
        config.make_excludes_absolute
      end
    rescue NoMethodError
      RuboCop::Config.new
    end

    # This is deprecated in favor of RuboCop's DisplayCopNames option.
    # Let's track how often we see this and remove it if we see fit.
    def rubocop_options
      if config.delete("ShowCopNames")
        Analytics.new(repository_owner_name).track_show_cop_names
        { debug: true }
      end
    end

    def default_config_file
      DefaultConfigFile.new(
        DEFAULT_CONFIG_FILENAME,
        repository_owner_name
      ).path
    end
  end
end
