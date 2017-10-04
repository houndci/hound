class ResolveConfigAliases
  ALIASES = {
    "coffeescript" => "coffee_script",
    "java_script" => "jshint",
    "javascript" => "jshint",
    "python" => "flake8",
    "sass-lint" => "sass_lint",
    "scss-lint" => "scss",
    "scss_lint" => "scss",
  }.freeze

  static_facade :call

  def initialize(config)
    @config = config
  end

  def call
    @config.reduce({}) do |resolved_config, (key, value)|
      if ALIASES.keys.include? key
        resolved_config[ALIASES[key]] = value
      else
        resolved_config[key] = value
      end
      resolved_config
    end
  end
end
