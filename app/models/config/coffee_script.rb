module Config
  class CoffeeScript < Base
    private

    def parse(file_content)
      Parser.json(file_content)
    end
  end
end
