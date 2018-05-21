module Config
  class Erblint < Base
    def serialize(data = content)
      Serializer.yaml(data)
    end
  end
end
