module Config
  class Swift < Base
    def serialize(data = content)
      Serializer.yaml(data)
    end
  end
end
