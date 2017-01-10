class ResolveConfigAliases
  ALIASES = {
    "javascript" => "jshint",
    "java_script" => "jshint",
    "coffeescript" => "coffee_script",
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
