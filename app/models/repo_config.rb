# Load and parse config files from GitHub repo
class RepoConfig
  HOUND_CONFIG = ".hound.yml"
  LANGUAGES = %w(ruby)
  FILE_TYPES = {
    "ruby" => "yaml",
    "javascript" => "json",
    "coffeescript" => "json",
    "scss" => "yaml",
  }

  class ParserError < StandardError; end

  pattr_initialize :commit

  def enabled_for?(language)
    options = options_for(language)
    options.nil? || !disabled?(language)
  end

  def for(language)
    config_file_path = config_path_for(language)
    config_type = FILE_TYPES.fetch(language)
    org_level_config = ENV["ORG_#{language.upcase}_CONFIG"]

    if config_file_path
      load_config(config_file_path, config_type)
    elsif org_level_config
      load_remote_config(org_level_config, config_type)
    else
      {}
    end
  end

  def ignored_javascript_files
    ignore_file_content = load_javascript_ignore

    if ignore_file_content.blank?
      ignore_file_content = File.read("config/style_guides/.jshintignore")
    end

    ignore_file_content.split("\n")
  end

  private

  def options_for(language)
    hound_config[language] || hound_config[language_camelize(language)]
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

  def load_remote_config(remote_path, file_type)
    client = commit.send(:github).client
    _, repo, path = *remote_path.match(/(.+?\/.+?)\/(.+)/)
    content = Base64.decode64(client.contents(repo, path: path).content)

    return {} unless content

    send("parse_#{file_type}", content)
  end

  def load_file(file_path, file_type)
    config_file_content = commit.file_content(file_path)

    if config_file_content.present?
      send("parse_#{file_type}", config_file_content)
    else
      {}
    end
  end

  def load_javascript_ignore
    ignore_file = hound_config.fetch("javascript", {}).
      fetch("ignore_file", ".jshintignore")

    commit.file_content(ignore_file)
  end

  def parse_yaml(content)
    YAML.safe_load(content, [Regexp])
  rescue Psych::Exception => e
    raise_repo_config_parser_error(e)
  end

  def parse_json(content)
    JSON.parse(content)
  rescue JSON::ParserError => e
    raise_repo_config_parser_error(e)
  end

  def raise_repo_config_parser_error(e)
    message = "#{e.class}: #{e.message}"
    raise RepoConfig::ParserError.new(message)
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
