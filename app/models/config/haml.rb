module Config
  class Haml < Base
    def serialize(data = content)
      Serializer.yaml(data)
    end
  end
end
