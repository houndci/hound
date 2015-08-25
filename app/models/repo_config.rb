# Load and parse config files from GitHub repo
class RepoConfig
  HOUND_CONFIG = ".hound.yml"
  BETA_LANGUAGES = %w(go haml python swift)
  LANGUAGES = %w(ruby coffeescript javascript scss haml go python swift)
  FILE_TYPES = {
    "ruby" => "yaml",
    "javascript" => "json",
    "coffeescript" => "json",
    "scss" => "yaml",
    "haml" => "yaml"
  }

  pattr_initialize :commit

  def enabled_for?(language)
    !disabled?(language)
  end

  def for(language)
    if language == "ruby" && legacy?
      hound_config
    else
      config_file_path = config_path_for(language)

      if config_file_path
        load_config(config_file_path, FILE_TYPES.fetch(language))
      else
        {}
      end
    end
  end

  def raw_for(language)
    config_file_path = config_path_for(language)

    if config_file_path
      commit.file_content(config_file_path)
    else
      ""
    end
  end

  def ignored_javascript_files
    ignore_file_content = load_javascript_ignore

    if ignore_file_content.blank?
      ignore_file_content = File.read("config/style_guides/.jshintignore")
    end

    ignore_file_content.split("\n")
  end

  def fail_on_violations?
    hound_config["fail_on_violations"]
  end

  private

  def beta?(language)
    BETA_LANGUAGES.include?(language)
  end

  def defualt_options_for(language)
    { "enabled" => !beta?(language) }
  end

  def options_for(language)
    hound_config[language] ||
      hound_config[language_camelize(language)] ||
      defualt_options_for(language)
  end

  def disabled?(language)
    options = options_for(language)
    options["enabled"] == false || options["Enabled"] == false
  end

  def hound_config
    @hound_config ||= begin
      config = load_file(HOUND_CONFIG, "yaml")
      if config.is_a?(Hash)
        convert_legacy_keys(config)
      else
        {}
      end
    end
  end

  def legacy?
    (configured_languages & LANGUAGES).empty?
  end

  def configured_languages
    hound_config.keys
  end

  def config_path_for(language)
    hound_config[language] &&
      hound_config[language]["config_file"]
  end

  def load_config(config_file_path, file_type)
    main_config = load_file(config_file_path, file_type)
    inherit_from = Array(main_config.fetch("inherit_from", []))

    inherited_config = inherit_from.reduce({}) do |config, ancestor_file_path|
      ancestor_config = load_file(ancestor_file_path, file_type)
      config.merge(ancestor_config)
    end

    inherited_config.merge(main_config.except("inherit_from"))
  end

  def load_file(file_path, file_type)
    config_file_content = commit.file_content(file_path)

    if config_file_content.present?
      send("parse_#{file_type}", file_path, config_file_content)
    else
      {}
    end
  end

  def load_javascript_ignore
    ignore_file = hound_config.fetch("javascript", {}).
      fetch("ignore_file", ".jshintignore")

    commit.file_content(ignore_file)
  end

  def parse_yaml(file_path, content)
    YAML.safe_load(content, [Regexp])
  rescue Psych::Exception => e
    raise_repo_config_parser_error(e, file_path)
  end

  def parse_json(file_path, content)
    JSON.parse(content)
  rescue JSON::ParserError => e
    raise_repo_config_parser_error(e, file_path)
  end

  def raise_repo_config_parser_error(e, file_path)
    message = "#{e.class}: #{e.message}"
    raise RepoConfig::ParserError.new(message, filename: file_path)
  end

  def convert_legacy_keys(config)
    converted_config = config.except("java_script", "coffee_script")

    if config["java_script"]
      converted_config["javascript"] = config["java_script"]
    end
    if config["coffee_script"]
      converted_config["coffeescript"] = config["coffee_script"]
    end

    converted_config
  end

  def language_camelize(language)
    case language.downcase
    when "coffeescript"
      "CoffeeScript"
    when "javascript"
      "JavaScript"
    else
      language.camelize
    end
  end
end
