module Config
  class Jshint < Base
    def serialize
      Serializer.json(content)
    end

    private

    def parse(content)
      Parser.json(content)
    end
  end
end
