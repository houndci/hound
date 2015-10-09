class HoundConfig
  CONFIG_FILE = ".hound.yml"
  BETA_LANGUAGES = %w(
    python
    swift
  )
  LANGUAGES = %w(
    coffeescript
    go
    haml
    javascript
    python
    ruby
    scss
    swift
  )

  attr_reader_initialize :commit

  def content
    @content ||= parse(commit.file_content(CONFIG_FILE))
  end

  def enabled_for?(name)
    supported_language?(name) || legacy_key?(name) || enabled?(name)
  end

  def fail_on_violations?
    !!(content["fail_on_violations"])
  end

  private

  LEGACY_LANGUAGE_KEY = %w(
    coffee_script
    java_script
  )

  def parse(file_content)
    Config::Parser.yaml(file_content) || {}
  end

  def supported_language?(name)
    (LANGUAGES - BETA_LANGUAGES).include?(name)
  end

  def legacy_key?(name)
    LEGACY_LANGUAGE_KEY.include?(name)
  end

  def enabled?(name)
    content[name] &&
      (content[name]["enabled"] || content[name]["Enabled"])
  end
end
