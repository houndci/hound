module Config
  class SlimLint < Base
    def serialize
      Serializer.yaml(content)
    end
  end
end
