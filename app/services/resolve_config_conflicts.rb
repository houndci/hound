class ResolveConfigConflicts
  CONFLICTS = {
    "eslint" => "jshint",
    "stylelint" => "scss",
    "sass_lint" => "scss",
  }.freeze

  static_facade :call

  def initialize(config)
    @config = config
  end

  def call
    @config.reduce({}) do |resolved_config, (linter, options)|
      if options
        if CONFLICTS.has_key?(linter) && options["enabled"] == true
          resolved_config[CONFLICTS[linter]] = { "enabled" => false }
        end
        resolved_config[linter] = options
      else
        raise Config::ParserError.new(
          "Missing options or invalid config format",
          linter_name: linter
        )
      end
      resolved_config
    end
  end
end
