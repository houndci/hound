module Config
  class Parser
    def self.yaml(content)
      if content.present?
        YAML.safe_load(content, [Regexp, Symbol])
      else
        {}
      end
    end

    def self.json(content)
      if content.present?
        JSON.parse(content)
      else
        {}
      end
    end

    def self.ini(content)
      IniFile.new(content: content).to_h
    end
  end
end
