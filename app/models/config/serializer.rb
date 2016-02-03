module Config
  class Serializer
    def self.yaml(data)
      data.to_yaml
    end

    def self.json(data)
      ActiveSupport::JSON.encode(data)
    end

    def self.ini(data)
      IniFile.new(content: data).to_s
    end
  end
end
