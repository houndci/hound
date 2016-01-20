module Config
  class CoffeeScript < Base
    private

    def parse(file_content)
      result = Parser.json(file_content)

      ensure_correct_type(result)
    end
  end
end
