class ConfigBuilder
  def self.for(hound_config, name)
    new(hound_config, name).config
  end

  def initialize(hound_config, name)
    @hound_config = hound_config
    @name = name
  end

  def config
    config_class.new(hound_config, name)
  end

  private

  attr_reader :hound_config, :name

  def config_class
    "Config::#{name.classify}".constantize
  rescue
    Config::Unsupported
  end
end
