module Config
  class Haml < Base
    def serialize
      Serializer.yaml(content)
    end
  end
end
