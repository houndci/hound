module Config
  class CoffeeLint < Base
    def linter_names
      [
        "coffeelint",
        "coffeescript",
        "coffee_script",
      ]
    end

    private

    def parse(file_content)
      Parser.json(file_content)
    end
  end
end
