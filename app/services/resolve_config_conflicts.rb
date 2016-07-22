class ResolveConfigConflicts
  CONFLICTS = { "eslint" => "jshint" }.freeze

  def self.run(config)
    new(config).run
  end

  def initialize(config)
    @config = config
  end

  def run
    @config.reduce({}) do |resolved_config, (linter, options)|
      if CONFLICTS.has_key?(linter) && options["enabled"] == true
        resolved_config[CONFLICTS[linter]] = { "enabled" => false }
      else
        resolved_config[linter] = options
      end
      resolved_config
    end
  end
end
