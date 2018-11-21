module Config
  class ErbLint < Base
    def serialize
      Serializer.yaml(content)
    end
  end
end
