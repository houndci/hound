module Config
  class Jshint < Base
    pattr_initialize :raw_content

    def serialize(data = content)
      Serializer.json(data)
    end

    def content
      @_content ||= ensure_correct_type(safe_parse(raw_content))
    end

    def merge(raw_overrides)
      parsed_overrides = parse(raw_overrides)
      merged_content = content.deep_merge(parsed_overrides)
      Config::Jshint.new(serialize(merged_content))
    end

    private

    def ensure_correct_type(config)
      if config.is_a? Hash
        config
      else
        raise_type_error
      end
    end

    def parse(file_content = raw_content)
      super(file_content)
    end

    def safe_parse(content)
      parse(content)
    rescue JSON::ParserError, Psych::Exception => exception
      raise_parse_error(exception.message)
    end
  end
end
