module Config
  class Jshint < Base
    def serialize(data = content)
      Serializer.json(data)
    end

    private

    def parse(content)
      rescue_and_raise_parse_error do
        Parser.json(content)
      end
    end
  end
end
