module Config
  class Parser
    def self.yaml(content)
      if content.present?
        YAML.safe_load(content, [Regexp, Symbol])
      else
        {}
      end
    rescue Psych::SyntaxError => error
      raise Config::ParserError.new(error.message, linter_name: nil)
    end

    def self.json(content)
      if content.present?
        JSON.parse(content)
      else
        {}
      end
    rescue JSON::ParserError => error
      raise Config::ParserError.new(error.message, linter_name: nil)
    end

    def self.ini(content)
      IniFile.new(content: content).to_h
    rescue IniFile::Error => error
      raise Config::ParserError.new(error.message, linter_name: nil)
    end
  end
end
