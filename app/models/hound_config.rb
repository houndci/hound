class HoundConfig
  CONFIG_FILE = ".hound.yml"
  BETA_LINTERS = %w(
    eslint
    jscs
    remark
    python
  ).freeze
  CONFIGURABLE_LINTERS = %w(
    coffeescript
    eslint
    go
    haml
    javascript
    jscs
    python
    python
    remark
    ruby
    scss
    swift
  ).freeze
  DEFAULT_LINTERS = CONFIGURABLE_LINTERS - BETA_LINTERS

  attr_reader_initialize :commit

  def content
    @content ||= parse(commit.file_content(CONFIG_FILE))
  end

  def enabled_for?(name)
    configured?(name)
  end

  def fail_on_violations?
    !!(content["fail_on_violations"])
  end

  private

  def parse(file_content)
    Config::Parser.yaml(file_content) || {}
  end

  def configured?(name)
    key = normalize_key(name)
    config = options_for(key)

    enabled?(config)
  end

  def enabled?(config)
    config["enabled"] || config["Enabled"]
  end

  def options_for(name)
    config = content[name] || {}
    default_options_for(name).merge(config)
  end

  def default_options_for(name)
    { "enabled" => default?(name) }
  end

  def default?(name)
    DEFAULT_LINTERS.include? name
  end

  def normalize_key(key)
    key.downcase.sub("_", "")
  end
end
