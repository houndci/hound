module Config
  class Haml < Base
    def serialize(data = content)
      Serializer.yaml(data)
    end

    def linter_names
      [
        "haml-lint",
        linter_name,
      ]
    end

    private

    def parse(file_content)
      Parser.yaml(file_content)
    end
  end
end
