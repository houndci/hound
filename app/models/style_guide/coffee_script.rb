# Determine CoffeeScript style guide violations per-line.
module StyleGuide
  class CoffeeScript < Base
    DEFAULT_CONFIG_FILENAME = "coffeescript.json"
    ERB_TAGS = /<%.*%>/

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

    def file_included?(*)
      true
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
      default_config.merge(repo_config.for(name))
    end

    def default_config
      config = File.read(default_config_file)
      JSON.parse(config)
    end

    def default_config_file
      DefaultConfigFile.new(
        DEFAULT_CONFIG_FILENAME,
        repository_owner_name
      ).path
    end

    def name
      "coffeescript"
    end
  end
end
