module Config
  class Swift < Base
    def linter_names
      [
        "swiftlint",
        linter_name,
      ]
    end

    def serialize(data = content)
      Serializer.yaml(data)
    end

    private

    def parse(file_content)
      Parser.yaml(file_content)
    end
  end
end
