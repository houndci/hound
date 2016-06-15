class RubyConfigBuilder
  HOUND_DEFAULTS_FILENAME = "ruby.yml".freeze
  VIRTUAL_FILENAME = "".freeze

  def initialize(content = {})
    @content = content
  end

  def config
    RuboCop::ConfigLoader.merge_with_default(
      normalized_content,
      VIRTUAL_FILENAME,
    )
  end

  def merge(overrides)
    RuboCop::ConfigLoader.merge(content, normalize_config(overrides))
  rescue NoMethodError, TypeError
    config
  end

  private

  attr_reader :content

  def normalized_content
    normalize_config(content)
  end

  def normalize_config(config)
    RuboCop::Config.new(config, VIRTUAL_FILENAME).tap do |new_config|
      new_config.add_missing_namespaces
      new_config.make_excludes_absolute
    end
  rescue NoMethodError, TypeError
    RuboCop::Config.new
  end
end
