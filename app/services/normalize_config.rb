class NormalizeConfig
  def self.run(config)
    new(config).run
  end

  def initialize(config)
    @config = config
  end

  def run
    @config.reduce({}) do |normalized_config, (key, value)|
      normalized_key = normalize_key(key)
      normalized_config[normalized_key] = if value.is_a? Hash
                                            NormalizeConfig.run(value)
                                          else
                                            value
                                          end
      normalized_config
    end
  end

  private

  def normalize_key(key)
    key.downcase
  end
end
