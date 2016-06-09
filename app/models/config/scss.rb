module Config
  class Scss < Base
    def serialize(data = content)
      Serializer.yaml(data)
    end

    def merge(config)
      serialize(content.deep_merge(config.content))
    end

    private

    def parse(file_content)
      Parser.yaml(file_content)
    end
  end
end
