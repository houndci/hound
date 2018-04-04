module Config
  class Flake8 < Base
    def serialize(data = content)
      Serializer.ini(data)
    end

    private

    def parse(file_content)
      rescue_and_raise_parse_error do
        content = SanitizeIniFile.call(file_content)
        Parser.ini(content)
      end
    end
  end
end
