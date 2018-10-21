module Config
  class HamlLint < Base
    def serialize
      Serializer.yaml(content)
    end
  end
end
