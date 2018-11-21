class ResolveConfigAliases
  ALIASES = {
    "coffeescript" => "coffeelint",
    "coffee_script" => "coffeelint",
    "erblint" => "erb_lint",
    "go" => "golint",
    "haml" => "haml_lint",
    "haml-lint" => "haml_lint",
    "java_script" => "jshint",
    "javascript" => "jshint",
    "python" => "flake8",
    "ruby" => "rubocop",
    "sass-lint" => "sass_lint",
    "scss-lint" => "scss_lint",
    "scss" => "scss_lint",
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
