module Config
  class Scss < Base
    pattr_initialize :raw_content

    def serialize(data = content)
      Serializer.yaml(data)
    end

    def content
      @_content ||= ensure_correct_type(safe_parse(raw_content))
    end

    def merge(raw_overrides)
      parsed_overrides = parse(raw_overrides)
      merged_content = content.deep_merge(parsed_overrides)
      Config::Scss.new(serialize(merged_content))
    end

    private

    def parse(file_content = raw_content)
      Config::Parser.yaml(file_content)
    end
  end
end
