module Config
  class Shellcheck < Base
    def serialize(data = content)
      Serializer.yaml(data)
    end
  end
end
