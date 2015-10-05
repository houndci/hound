module Linter
  class Ruby < Base
    FILE_REGEXP = /.+\.rb\z/

    def file_review(commit_file)
      perform_file_review(commit_file)
    end

    def file_included?(commit_file)
      !config.file_to_exclude?(commit_file.filename)
    end

    private

    def perform_file_review(commit_file)
      FileReview.create!(filename: commit_file.filename) do |file_review|
        team.inspect_file(parsed_source(commit_file)).each do |violation|
          line = commit_file.line_at(violation.line)
          file_review.build_violation(line, violation.message)
        end

        file_review.build = build
        file_review.complete
      end
    end

    def team
      RuboCop::Cop::Team.new(RuboCop::Cop::Cop.all, config, rubocop_options)
    end

    def parsed_source(commit_file)
      absolute_filepath = File.expand_path(commit_file.filename)
      RuboCop::ProcessedSource.new(commit_file.content, absolute_filepath)
    end

    def config
      @config ||= RuboCop::ConfigLoader.merge_with_default(custom_config, "")
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
  end
end
