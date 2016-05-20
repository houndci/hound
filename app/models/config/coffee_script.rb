module Config
  class CoffeeScript < Base
    def linter_names
      [
        "coffeelint",
        linter_name,
        linter_name.sub("_", ""),
      ]
    end

    private

    def parse(file_content)
      Parser.json(file_content)
    end
  end
end
