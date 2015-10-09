module Config
  class CoffeeScript < Base
    private

    def parse(file_content)
      result = Parser.json(file_content)

      ensure_correct_type(result)
    end

    def linter_config
      super || hound_config.content[alternate_linter_name]
    end

    def alternate_linter_name
      linter_name.sub("_", "")
    end
  end
end
