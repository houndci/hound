# Determine CoffeeScript style guide violations per-line.
module Linter
  class CoffeeScript < Base
    ERB_TAGS = /<%.*%>/
    FILE_REGEXP = /.+\.coffee(\.js)?(\.erb)?\z/

    def file_review(commit_file)
      FileReview.create!(filename: commit_file.filename) do |file_review|
        content = content_for_file(commit_file)

        lint(content).each do |violation|
          line = commit_file.line_at(violation["lineNumber"])
          file_review.build_violation(line, violation["message"])
        end

        file_review.build = build
        file_review.complete
      end
    end

    private

    def lint(content)
      Coffeelint.lint(content, config)
    end

    def content_for_file(file)
      if erb? file
        file.content.gsub(ERB_TAGS, "123")
      else
        file.content
      end
    end

    def erb?(file)
      file.filename.ends_with? ".erb"
    end

    def config
      repo_config.for(name)
    end

    def name
      "coffeescript"
    end
  end
end
