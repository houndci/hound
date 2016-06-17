# Determine Ruby style guide violations per-line.
module Linter
  class Ruby < Base
    FILE_REGEXP = /.+\.rb\z/
    RUBY_PARSER_VERSION = 2.3

    def file_review(commit_file)
      perform_file_review(commit_file)
    end

    def file_included?(commit_file)
      !merged_config.file_to_exclude?(commit_file.filename)
    end

    private

    def perform_file_review(commit_file)
      FileReview.create!(
        filename: commit_file.filename,
        linter_name: name,
      ) do |file_review|
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
        merged_config,
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

    def merged_config
      @merged_config ||=
        if build.repo.owner.has_config_repo?
          rubocop_config_builder(owner_config.content).
            merge(repo_config.content)
        else
          rubocop_config_builder(repo_config.content).config
        end
    end

    def rubocop_config_builder(content)
      RubyConfigBuilder.new(content)
    end

    def owner_config
      ConfigBuilder.for(owner_hound_config, "ruby")
    end

    def owner_hound_config
      BuildOwnerHoundConfig.run(build.repo.owner)
    end

    def repo_config
      ConfigBuilder.for(repo_hound_config, "ruby")
    end

    def repo_hound_config
      hound_config
    end

    # This is deprecated in favor of RuboCop's DisplayCopNames option.
    # Let's track how often we see this and remove it if we see fit.
    def rubocop_options
      if merged_config.delete("ShowCopNames")
        Analytics.new(build.full_github_name).track_show_cop_names
        { debug: true }
      end
    end
  end
end
