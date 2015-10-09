module Config
  class Parser
    def self.yaml(content)
      YAML.safe_load(content, [Regexp])
    end

    def self.json(content)
      JSON.parse(content)
    end

    def self.raw(content)
      content
    end
  end
end
