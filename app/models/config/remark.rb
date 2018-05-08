module Config
  class Remark < Base
    def serialize
      Serializer.json(content)
    end
  end
end
