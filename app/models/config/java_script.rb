module Config
  class JavaScript < Base
    DEFAULT_EXCLUDED_FILES = %w(vendor/*)

    def excluded_files
      @excluded_files ||= (
        load_javascript_ignore.presence ||
        DEFAULT_EXCLUDED_FILES
      )
    end

    private

    def parse(file_content)
      result = Parser.json(file_content)

      ensure_correct_type(result)
    end

    def load_javascript_ignore
      ignore_file = hound_config.content.
        fetch("javascript", {}).
        fetch("ignore_file", ".jshintignore")

      commit.file_content(ignore_file).to_s.split("\n")
    end

    def linter_config
      super || hound_config.content[alternate_linter_name]
    end

    def alternate_linter_name
      linter_name.sub("_", "")
    end
  end
end
