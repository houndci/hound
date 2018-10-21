module Config
  class ScssLint < Base
    def serialize
      Serializer.yaml(content)
    end
  end
end
