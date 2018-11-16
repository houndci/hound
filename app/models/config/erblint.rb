module Config
  class Erblint < Base
    def serialize
      Serializer.yaml(content)
    end
  end
end
