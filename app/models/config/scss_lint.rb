module Config
  class ScssLint < Base
    def serialize(data = content)
      Serializer.yaml(data)
    end

    def linter_names
      [
        "scss",
        "scsslint",
        "scss-lint",
      ]
    end

    private

    def parse(file_content)
      Parser.yaml(file_content)
    end
  end
end
