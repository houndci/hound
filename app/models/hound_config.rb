class HoundConfig
  CONFIG_FILE = ".hound.yml"
  LANGUAGES = %w(
    coffeescript
    eslint
    go
    haml
    javascript
    jscs
    jshint
    mdast
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
    if config.has_key? "enabled"
      !!config["enabled"]
    elsif config.has_key? "Enabled"
      !!config["Enabled"]
    else
      config["config_file"].present?
    end
  end

  def options_for(name)
    content[name] || {}
  end

  def normalize_key(key)
    key.downcase.sub("_", "")
  end
end
