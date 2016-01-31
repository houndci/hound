class RubyConfigBuilder
  HOUND_DEFAULTS_FILENAME = "ruby.yml".freeze
  VIRTUAL_FILENAME = "".freeze

  def initialize(overrides = {}, repository_owner_name = nil)
    @overrides = overrides
    @repository_owner_name = repository_owner_name
  end

  def config
    RuboCop::ConfigLoader.merge_with_default(
      combined_overrides,
      VIRTUAL_FILENAME,
    )
  end

  private

  attr_reader :overrides, :repository_owner_name

  def combined_overrides
    RuboCop::ConfigLoader.merge(normalized_hound_config, normalized_overrides)
  rescue TypeError
    hound_config
  end

  def normalized_overrides
    normalize_config(overrides)
  end

  def normalized_hound_config
    normalize_config(hound_config)
  end

  def hound_config
    Config::Parser.yaml(File.read(hound_config_filepath))
  end

  def hound_config_filepath
    DefaultConfigFile.new(HOUND_DEFAULTS_FILENAME, repository_owner_name).path
  end

  def normalize_config(config)
    RuboCop::Config.new(config, VIRTUAL_FILENAME).tap do |new_config|
      new_config.add_missing_namespaces
      new_config.make_excludes_absolute
    end
  rescue NoMethodError
    RuboCop::Config.new
  end
end
