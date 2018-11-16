module Config
  class Rubocop < Base
    def serialize
      Serializer.yaml(content)
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
  end
end
