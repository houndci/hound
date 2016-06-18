module Config
  class SwiftLint < Base
    def linter_names
      %w(
        swift
        swiftlint
      )
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
