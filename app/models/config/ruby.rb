module Config
  class Ruby < Base
    def content
      if legacy?
        hound_config.content
      else
        parse_inherit_from(super)
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
        ancestor_config = safe_parse(raw_ancestor_config) || {}
        result.merge(ancestor_config)
      end

      merged_config = inherited_config.merge(config.except("inherit_from"))

      if merged_config.has_key?("inherit_from")
        parse_inherit_from(merged_config)
      else
        merged_config
      end
    end

    def legacy?
      (configured_languages & HoundConfig::LANGUAGES).empty?
    end

    def configured_languages
      hound_config.content.keys
    end
  end
end
