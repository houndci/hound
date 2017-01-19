module Config
  class CoffeeScript < Base
    def serialize(data = content)
      Serializer.json(data)
    end
  end
end
