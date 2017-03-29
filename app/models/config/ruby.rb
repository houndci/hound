module Config
  class Ruby < Base
    def content
      if legacy?
        hound_config.content
      else
        super
      end
    end

    def serialize(data = content)
      Serializer.yaml(data)
    end

    private

    def load
      config = super
      inherited_config = parse_inherit_from(config)
      inherited_config.deep_merge(config.except("inherit_from"))
    end

    def parse_inherit_from(config)
      inherit_from = Array(config.fetch("inherit_from", []))

      inherit_from.reduce({}) do |result, ancestor_file_path|
        raw_ancestor_config = commit.file_content(ancestor_file_path)
        ancestor_config = safe_parse(raw_ancestor_config) || {}
        result.merge(ancestor_config)
      end
    end

    def safe_parse(content)
      parse(content)
    rescue Psych::Exception => exception
      raise_parse_error(exception.message)
    end

    def legacy?
      (configured_languages & all_linter_names).empty?
    end

    def all_linter_names
      HoundConfig::LINTERS.keys.map { |klass| klass.name.demodulize.underscore }
    end

    def configured_languages
      hound_config.content.keys
    end
  end
end
