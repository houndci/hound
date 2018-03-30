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
      if options.nil?
        raise Config::ParserError.new(
          "Invalid #{linter} config or options are missing.",
          linter_name: linter,
        )
      else
        if CONFLICTS.has_key?(linter) && options["enabled"] == true
          resolved_config[CONFLICTS[linter]] = { "enabled" => false }
        end
        resolved_config[linter] = options
      end
      resolved_config
    end
  end
end
