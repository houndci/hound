module Config
  class Scss < Base
    def serialize
      Serializer.yaml(content)
    end
  end
end
