# frozen_string_literal: true

class NormalizeConfig
  static_facade :call

  def initialize(config)
    @config = config
  end

  def call
    @config.reduce({}) do |normalized_config, (key, value)|
      normalized_key = normalize_key(key)
      if value.is_a? Hash
        normalized_config[normalized_key] = NormalizeConfig.call(value)
      else
        normalized_config[normalized_key] = value
      end
      normalized_config
    end
  end

  private

  def normalize_key(key)
    key.downcase
  end
end
