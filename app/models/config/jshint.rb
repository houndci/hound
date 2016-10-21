module Config
  class Jshint < Base
    pattr_initialize :raw_content

    def serialize(overrides = default_content)
      Serializer.json(merge(overrides))
    end

    private

    def content
      @_content ||= ensure_correct_type(safe_parse(raw_content))
    end

    def merge(raw_overrides)
      parsed_overrides = parse(raw_overrides)
      content.deep_merge(parsed_overrides)
    end

    def parse(file_content = raw_content)
      Parser.json(file_content)
    end
  end
end
