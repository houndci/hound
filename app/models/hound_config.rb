# frozen_string_literal: true
class HoundConfig
  BETA_LINTERS = %w(
    eslint
    jscs
    jshint
    remark
    python
  ).freeze
  CONFIG_FILE = ".hound.yml"

  attr_reader_initialize :commit

  def content
    @content ||= parse(commit.file_content(CONFIG_FILE))
  end

  def linter_enabled?(name)
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
    { "enabled" => !beta?(name) }
  end

  def beta?(name)
    BETA_LINTERS.include?(name)
  end

  def normalize_key(key)
    key.downcase.sub("_", "")
  end
end
