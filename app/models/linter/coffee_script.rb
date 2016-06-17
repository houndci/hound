# Determine CoffeeScript style guide violations per-line.
module Linter
  class CoffeeScript < Base
    ERB_TAGS = /<%.*%>/
    FILE_REGEXP = /.+\.coffee(\.js)?(\.erb)?\z/

    def file_review(commit_file)
      FileReview.create!(
        filename: commit_file.filename,
        linter_name: name,
      ) do |file_review|
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
      Coffeelint.lint(content, merged_config)
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

    def merged_config
      owner_config.merge(repo_config)
    end

    def owner_config
      ConfigBuilder.for(owner_hound_config, "coffee_script")
    end

    def repo_config
      ConfigBuilder.for(repo_hound_config, "coffee_script")
    end

    def repo_hound_config
      hound_config
    end

    def owner_hound_config
      BuildOwnerHoundConfig.run(build.repo.owner)
    end
  end
end
