class CheckEnabledLinter
  def self.run(*configs)
    new(*configs).enabled?
  end

  def initialize(*configs)
    @configs = configs
  end

  def enabled?
    if disabled?
      return false
    end

    linter_names.any? do |linter_name|
      hound_configs.any? do |hound_config|
        hound_config.enabled_for?(linter_name)
      end
    end
  end

  private

  def disabled?
    linter_names.any? do |linter_name|
      hound_configs.any? do |hound_config|
        hound_config.disabled_for?(linter_name)
      end
    end
  end

  def linter_names
    @configs.flat_map(&:linter_names)
  end

  def hound_configs
    @configs.flat_map(&:hound_config)
  end
end
