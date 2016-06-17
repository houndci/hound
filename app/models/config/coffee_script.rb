module Config
  class CoffeeScript < Base
    def merge(config)
      content.deep_merge(config.content)
    end

    private

    def parse(file_content)
      Parser.json(file_content)
    end
  end
end
