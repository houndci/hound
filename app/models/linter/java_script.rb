module Linter
  class JavaScript < Base
    FILE_REGEXP = /.+(?<!\.coffee)\.js\z/

    def file_review(commit_file)
      FileReview.create!(filename: commit_file.filename) do |file_review|
        Jshintrb.lint(commit_file.content, config).compact.each do |violation|
          line = commit_file.line_at(violation["line"])
          file_review.build_violation(line, violation["reason"])
        end

        file_review.build = build
        file_review.complete
      end
    end

    def file_included?(commit_file)
      !excluded_files.any? do |pattern|
        File.fnmatch?(pattern, commit_file.filename)
      end
    end

    private

    def config
      if custom_config["predef"].present?
        custom_config["predef"] |= default_config["predef"]
      end

      custom_config
    end

    def custom_config
      @custom_config ||= repo_config.for(name)
    end

    def excluded_files
      repo_config.ignored_javascript_files
    end

    def name
      "javascript"
    end
  end
end
