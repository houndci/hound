# Determine Ruby style guide violations per-line.
module Linter
  class Ruby < Base
    FILE_REGEXP = /.+\.rb\z/
    RUBY_PARSER_VERSION = 2.3

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
      RuboCop::ProcessedSource.new(
        commit_file.content,
        RUBY_PARSER_VERSION,
        File.join(Rails.root, commit_file.filename),
      )
    end

    def linter_config
      @linter_config ||= config_builder.config
    end

    def config_builder
      RubyConfigBuilder.new(config.content, repository_owner_name)
    end

    # This is deprecated in favor of RuboCop's DisplayCopNames option.
    # Let's track how often we see this and remove it if we see fit.
    def rubocop_options
      if linter_config.delete("ShowCopNames")
        Analytics.new(repository_owner_name).track_show_cop_names
        { debug: true }
      end
    end
  end
end
