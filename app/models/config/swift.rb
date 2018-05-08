module Config
  class Swift < Base
    def serialize
      Serializer.yaml(content)
    end
  end
end
