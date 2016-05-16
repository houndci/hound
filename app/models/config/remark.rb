module Config
  class Remark < Base
    def serialize(data = content)
      Serializer.json(data)
    end

    private

    def parse(file_content)
      Parser.json(file_content)
    end
  end
end
