module Config
  class CoffeeScript < Base
    def content
      owner_config.deep_merge(super)
    end

    def serialize(data = content)
      Serializer.json(data)
    end

    private

    def parse(file_content)
      Parser.json(file_content)
    end
  end
end
