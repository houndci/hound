module Config
  class Flake8 < Base
    def serialize
      Serializer.ini(content)
    end

    private

    def parse(file_content)
      content = SanitizeIniFile.call(file_content)
      Parser.ini(content)
    end
  end
end
