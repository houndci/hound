module Config
  class SlimLint < Base
    def serialize(data = content)
      Serializer.yaml(data)
    end
  end
end
