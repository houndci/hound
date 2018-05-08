module Config
  class SassLint < Base
    def serialize
      Serializer.yaml(content)
    end
  end
end
