module Config
  class Swiftlint < Base
    def serialize
      Serializer.yaml(content)
    end
  end
end
