module Config
  class Jshint < Base
    def serialize(data = content)
      Serializer.json(data)
    end
  end
end
