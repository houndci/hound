# Load and parse config files from GitHub repo
class RepoConfig
  HOUND_CONFIG = ".hound.yml"
  LANGUAGES = %w(ruby coffee_script java_script scss)
  FILE_TYPES = {
    "ruby" => "yaml",
    "java_script" => "json",
    "coffee_script" => "json",
    "scss" => "yaml",
  }
  DEFAULT_IGNORED_DIRECTORIES = ["vendor"]

  pattr_initialize :commit

  def enabled_for?(language)
    options = options_for(language)
    options.nil? || !disabled?(language)
  end

  def for(language)
    if language == "ruby" && legacy?
      hound_config
    else
      config_file_path = config_path_for(language)

      if config_file_path
        load_file(config_file_path, FILE_TYPES.fetch(language))
      else
        {}
      end
    end
  end

  def ignored_javascript_files
    ignore_file_content = load_javascript_ignore

    if ignore_file_content.present?
      ignore_file_content.split("\n")
    else
      []
    end
  end

  def ignored_directories
    remote_hound_config = load_file(HOUND_CONFIG, "yaml")
    remote_hound_config["ignored_directories"] || DEFAULT_IGNORED_DIRECTORIES
  end

  private

  def options_for(language)
    hound_config[language] || hound_config[language.camelize]
  end

  def disabled?(language)
    options = options_for(language)
    options["enabled"] == false || options["Enabled"] == false
  end

  def hound_config
    @hound_config ||= begin
      config = load_file(HOUND_CONFIG, "yaml")
      if config.is_a?(Hash)
        config
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

  def load_file(file_path, file_type)
    config_file_content = commit.file_content(file_path)

    if config_file_content.present?
      send("parse_#{file_type}", config_file_content)
    else
      {}
    end
  end

  def load_javascript_ignore
    ignore_file = hound_config.fetch("java_script", {}).
      fetch("ignore_file", ".jshintignore")

    commit.file_content(ignore_file)
  end

  def parse_yaml(content)
    YAML.load(content)
  rescue Psych::SyntaxError
    {}
  end

  def parse_json(content)
    JSON.parse(content)
  rescue JSON::ParserError
    {}
  end
end
