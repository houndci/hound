module Config
  class Scss < Base
    def serialize(data = content)
      Serializer.yaml(data)
    end

    private

    def parse(file_content)
      Parser.yaml(file_content)
    end
  end
end
