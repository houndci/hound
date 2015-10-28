module Config
  class Ruby < Base
    def content
      if legacy?
        hound_config.content
      else
        result = super
        ensure_correct_type(result)
        parse_inherit_from(result)
      end
    end

    private

    def parse(file_content)
      Parser.yaml(file_content)
    end

    def parse_inherit_from(config)
      inherit_from = Array(config.fetch("inherit_from", []))

      inherited_config = inherit_from.reduce({}) do |result, ancestor_file_path|
        raw_ancestor_config = commit.file_content(ancestor_file_path)
        ancestor_config = parse(raw_ancestor_config) || {}
        result.merge(ancestor_config)
      end

      inherited_config.merge(config.except("inherit_from"))
    end

    def legacy?
      (configured_languages & HoundConfig::LANGUAGES).empty?
    end

    def configured_languages
      hound_config.content.keys
    end
  end
end
