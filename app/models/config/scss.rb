module Config
  class Scss < Base
    def serialize(data = content)
      Serializer.yaml(data)
    end
  end
end
