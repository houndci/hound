class RubyConfigBuilder
  HOUND_DEFAULTS_FILENAME = "ruby.yml".freeze

  def initialize(overrides = {}, repository_owner_name = nil)
    @overrides = overrides
    @repository_owner_name = repository_owner_name
  end

  def config
    RuboCop::Config.new(merged_config, "")
  end

  private

  attr_reader :overrides, :repository_owner_name

  def merged_config
    RuboCop::ConfigLoader.merge(combined_defaults, normalized_overrides)
  rescue TypeError
    combined_defaults
  end

  def combined_defaults
    RuboCop::ConfigLoader.configuration_from_file(hound_config_filepath)
  end

  def hound_config_filepath
    DefaultConfigFile.new(HOUND_DEFAULTS_FILENAME, repository_owner_name).path
  end

  def normalized_overrides
    RuboCop::Config.new(overrides, "").tap do |custom_config|
      custom_config.add_missing_namespaces
      custom_config.make_excludes_absolute
    end
  rescue NoMethodError
    RuboCop::Config.new
  end
end
