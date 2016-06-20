module Config
  class HamlLint < Base
    def serialize(data = content)
      Serializer.yaml(data)
    end

    def linter_names
      [
        "haml",
        "haml-lint",
      ]
    end

    private

    def parse(file_content)
      Parser.yaml(file_content)
    end
  end
end
