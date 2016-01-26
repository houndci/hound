module Config
  class CoffeeScript < Base
    def linter_names
      [
        linter_name,
        linter_name.sub("_", ""),
      ]
    end

    private

    def parse(file_content)
      result = Parser.json(file_content)

      ensure_correct_type(result)
    end
  end
end
