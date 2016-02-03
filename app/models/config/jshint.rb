module Config
  class Jshint < Base
    DEFAULT_EXCLUDED_FILES = %w(vendor/*).freeze

    def excluded_files
      @excluded_files ||= (
        load_javascript_ignore.presence || DEFAULT_EXCLUDED_FILES
      )
    end

    def linter_names
      [
        "javascript",
        "java_script",
        linter_name,
      ]
    end

    def serialize(data = content)
      Serializer.json(data)
    end

    private

    def parse(file_content)
      Parser.json(file_content)
    end

    def load_javascript_ignore
      ignore_file = hound_config.content.
        fetch("javascript", {}).
        fetch("ignore_file", ".jshintignore")

      commit.file_content(ignore_file).to_s.split("\n")
    end
  end
end
