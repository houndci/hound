module Config
  class CoffeeScript < Base
    private

    def parse(file_content)
      result = Parser.json(file_content)

      ensure_correct_type(result)
    end

    def linter_names
      [
        linter_name,
        linter_name.sub("_", ""),
      ]
    end
  end
end
