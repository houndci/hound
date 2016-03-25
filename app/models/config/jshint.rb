module Config
  class Jshint < Base
    def linter_names
      [
        "javascript",
        "java_script",
        linter_name,
      ]
    end

    def serialize(data = content)
      Serializer.json(data)
    end

    private

    def parse(file_content)
      Parser.json(file_content)
    end
  end
end
