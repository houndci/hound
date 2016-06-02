class HoundConfig
  CONFIG_FILE = ".hound.yml"

  attr_reader_initialize :commit

  def content
    @content ||= parse(commit.file_content(CONFIG_FILE))
  end

  def disabled_for?(name)
    key = normalize_key(name)
    config = options_for(key)

    config_enabled(config) === false
  end

  def enabled_for?(name)
    key = normalize_key(name)
    config = options_for(key)

    config_enabled(config)
  end

  def fail_on_violations?
    !!(content["fail_on_violations"])
  end

  private

  def parse(file_content)
    Config::Parser.yaml(file_content) || {}
  end

  def options_for(name)
    content.fetch(name, {})
  end

  def config_enabled(config)
    config.fetch("enabled", config["Enabled"])
  end

  def normalize_key(key)
    key.downcase.sub("_", "")
  end
end
