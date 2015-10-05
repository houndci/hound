module Linter
  class Haml < Base
    FILE_REGEXP = /.+\.haml\z/

    def file_review(commit_file)
      @commit_file = commit_file

      FileReview.create!(filename: commit_file.filename) do |file_review|
        run_linters.map do |violation|
          line = commit_file.line_at(violation.line)

          file_review.build_violation(line, violation.message)
        end

        file_review.build = build
        file_review.complete
      end
    end

    def file_included?(filename)
      !file_excluded?(filename)
    end

    private

    def file_excluded?(filename)
      HamlLint::Utils.any_glob_matches?(config["exclude"], filename)
    end

    attr_reader :commit_file

    def content
      HamlLint::Document.new(
        commit_file.content,
        file: commit_file.filename,
        config: config,
      )
    end

    def run_linters
      linters.reduce([]) do |results, linter|
        linter.run(content)
        results + linter.lints
      end
    end

    def linters
      HamlLint::LinterSelector.new(config, {}).
        linters_for_file(commit_file.filename)
    end

    def config
      HamlLint::ConfigurationLoader.default_configuration.
        merge(custom_config)
    end

    def custom_config
      HamlLint::Configuration.new(repo_config.for(name))
    end
  end
end
