module Config
  class Jshint < Base
    def serialize(data = content)
      Serializer.json(data)
    end

    private

    def parse(content)
      Parser.json(content)
    end
  end
end
