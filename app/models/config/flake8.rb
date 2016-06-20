module Config
  class Flake8 < Base
    def linter_names
      [
        "python",
        linter_name,
      ]
    end

    def content
      @content ||= super.presence || default_content
    end

    def serialize(data = content)
      Serializer.ini(data)
    end

    private

    def parse(file_content)
      Parser.ini(file_content)
    end

    def default_content
      ""
    end
  end
end
