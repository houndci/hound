module Config
  class Ruby < Base
    def initialize(hound_config, owner: nil)
      super(hound_config)
      @owner = owner
    end

    def content
      if legacy?
        hound_config.content
      else
        owner_config_content.deep_merge(parse_inherit_from(super))
      end
    end

    def serialize(data = content)
      Serializer.yaml(data)
    end

    private

    def parse(file_content)
      Parser.yaml(file_content)
    end

    def owner_config_content
      if @owner.present?
        Config::Ruby.new(owner_hound_config).content
      else
        {}
      end
    end

    def owner_hound_config
      BuildOwnerHoundConfig.run(@owner)
    end

    def parse_inherit_from(config)
      inherit_from = Array(config.fetch("inherit_from", []))

      inherited_config = inherit_from.reduce({}) do |result, ancestor_file_path|
        raw_ancestor_config = commit.file_content(ancestor_file_path)
        ancestor_config = safe_parse(raw_ancestor_config) || {}
        result.merge(ancestor_config)
      end

      inherited_config.merge(config.except("inherit_from"))
    end

    def legacy?
      (configured_languages & HoundConfig::LINTER_NAMES).empty?
    end

    def configured_languages
      hound_config.content.keys
    end
  end
end
