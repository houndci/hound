module Config
  class Reek < Base
    def serialize
      Serializer.yaml(content)
    end
  end
end
