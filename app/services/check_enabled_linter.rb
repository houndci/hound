class CheckEnabledLinter
  BETA_LINTERS = %w(
    eslint
    jscs
    remark
    python
  ).freeze
  DEFAULT_LINTERS = (Linter::Collection::LINTER_NAMES - BETA_LINTERS).freeze

  def self.run(*configs)
    new(*configs).enabled?
  end

  def initialize(*configs)
    @configs = configs
  end

  def enabled?
    !any_alias_disabled? && (any_alias_enabled? || any_alias_default?)
  end

  private

  def any_alias_disabled?
    linter_names.any? do |linter_name|
      hound_configs.any? do |hound_config|
        hound_config.disabled_for?(linter_name)
      end
    end
  end

  def any_alias_enabled?
    linter_names.any? do |linter_name|
      hound_configs.any? do |hound_config|
        hound_config.enabled_for?(linter_name)
      end
    end
  end

  def any_alias_default?
    linter_names.any? do |linter_name|
      DEFAULT_LINTERS.include? linter_name
    end
  end

  def linter_names
    @configs.flat_map(&:linter_names)
  end

  def hound_configs
    @configs.flat_map(&:hound_config)
  end
end
