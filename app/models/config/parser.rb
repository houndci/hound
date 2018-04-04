module Config
  class Parser
    def self.yaml(content)
      if content.present?
        YAML.safe_load(content, [Regexp, Symbol])
      else
        {}
      end
    rescue Psych::SyntaxError
      raise Config::ParserError
    end

    def self.json(content)
      if content.present?
        JSON.parse(content)
      else
        {}
      end
    rescue JSON::ParserError
      raise Config::ParserError
    end

    def self.ini(content)
      IniFile.new(content: content).to_h
    rescue IniFile::Error
      raise Config::ParserError
    end
  end
end
