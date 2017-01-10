class ResolveConfigConflicts
  CONFLICTS = { "eslint" => "jshint" }.freeze

  static_facade :call

  def initialize(config)
    @config = config
  end

  def call
    @config.reduce({}) do |resolved_config, (linter, options)|
      if CONFLICTS.has_key?(linter) && options["enabled"] == true
        resolved_config[CONFLICTS[linter]] = { "enabled" => false }
      end
      resolved_config[linter] = options
      resolved_config
    end
  end
end
