module Config
  class Shellcheck < Base
    def serialize
      Serializer.yaml(content)
    end
  end
end
