# Determine Ruby style guide violations per-line.
module Linter
  class Ruby < Base
    DEFAULT_CONFIG_FILENAME = "ruby.yml"
    FILE_REGEXP = /.+\.rb\z/

    def file_review(commit_file)
      perform_file_review(commit_file)
    end

    def file_included?(commit_file)
      !linter_config.file_to_exclude?(commit_file.filename)
    end

    private

    def perform_file_review(commit_file)
      FileReview.create!(filename: commit_file.filename) do |file_review|
        permitted_rubocop_offenses(commit_file).each do |violation|
          line = commit_file.line_at(violation.line)
          file_review.build_violation(line, violation.message)
        end

        file_review.build = build
        file_review.complete
      end
    end

    def permitted_rubocop_offenses(commit_file)
      team.inspect_file(parsed_source(commit_file)).reject(&:disabled?)
    end

    def team
      RuboCop::Cop::Team.new(
        RuboCop::Cop::Cop.all,
        linter_config,
        rubocop_options,
      )
    end

    def parsed_source(commit_file)
      absolute_filepath = File.expand_path(commit_file.filename)
      RuboCop::ProcessedSource.new(commit_file.content, absolute_filepath)
    end

    def linter_config
      @linter_config ||= RuboCop::Config.new(merged_config, "")
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
      RuboCop::Config.new(config.content, "").tap do |custom_config|
        custom_config.add_missing_namespaces
        custom_config.make_excludes_absolute
      end
    rescue NoMethodError
      RuboCop::Config.new
    end

    # This is deprecated in favor of RuboCop's DisplayCopNames option.
    # Let's track how often we see this and remove it if we see fit.
    def rubocop_options
      if linter_config.delete("ShowCopNames")
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
