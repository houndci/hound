module Config
  class Jscs < Base
    def serialize(data = content)
      Serializer.json(data)
    end

    private

    def parse(file_content)
      Parser.yaml(file_content)
    end

    def default_content
      {}
    end
  end
end
