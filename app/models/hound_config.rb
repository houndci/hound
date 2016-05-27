class HoundConfig
  CONFIG_FILE = ".hound.yml"
  BETA_LINTERS = %w(
    eslint
    jscs
    remark
    python
  ).freeze
  DEFAULT_LINTERS = (Linter::Collection::LINTER_NAMES - BETA_LINTERS).freeze

  attr_reader_initialize :commit

  def content
    @content ||= parse(commit.file_content(CONFIG_FILE))
  end

  def disabled_for?(name)
    key = normalize_key(name)
    config = options_for(key)

    disabled?(config)
  end

  def enabled_for?(name)
    key = normalize_key(name)
    config = options_for(key)

    enabled?(config) || default?(key)
  end

  def fail_on_violations?
    !!(content["fail_on_violations"])
  end

  private

  def parse(file_content)
    Config::Parser.yaml(file_content) || {}
  end

  def enabled?(config)
    config["enabled"] || config["Enabled"]
  end

  def disabled?(config)
    config["enabled"] == false || config["Enabled"] == false
  end

  def options_for(name)
    content[name] || {}
  end

  def default?(name)
    DEFAULT_LINTERS.include? name
  end

  def normalize_key(key)
    key.downcase.sub("_", "")
  end
end
