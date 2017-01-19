module Config
  class Python < Base
    def serialize(data = content)
      Serializer.ini(data)
    end

    private

    def parse(file_content)
      Parser.ini(file_content)
    end
  end
end
