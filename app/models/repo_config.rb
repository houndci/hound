# Load and parse config files from GitHub repo
class RepoConfig
  FILE_TYPES = {
    "ruby" => "yaml",
    "java_script" => "json",
    "coffee_script" => "json",
  }
  HOUND_CONFIG_FILE = ".hound.yml"
  STYLE_GUIDES = %w(ruby coffee_script java_script)
  DEFAULT_CONFIG = {
    "pull_requests" => { "enabled" => true },
    "pushes" => { "enabled" => false }
  }

  pattr_initialize :commit

  def enabled_for?(style_guide_name)
    style_guide_name == "ruby" && legacy_config? ||
      enabled_in_config?(style_guide_name)
  end

  def for(style_guide_name)
    if style_guide_name == "ruby" && legacy_config?
      hound_config.except(*DEFAULT_CONFIG.keys)
    else
      config_file_path = config_path_for(style_guide_name)

      if config_file_path
        load_file(config_file_path, FILE_TYPES[style_guide_name])
      else
        {}
      end
    end
  end

  private

  def enabled_in_config?(name)
    config = hound_config[name] || hound_config[name.camelize]
    config && (config["enabled"] == true || config["Enabled"] == true)
  end

  def legacy_config?
    (hound_config.keys & STYLE_GUIDES).empty?
  end

  def hound_config
    @hound_config ||= begin
      content = load_file(HOUND_CONFIG_FILE, "yaml")
      if content.is_a?(Hash)
        DEFAULT_CONFIG.merge(content)
      else
        DEFAULT_CONFIG
      end
    end
  end

  def config_path_for(style_guide_name)
    hound_config[style_guide_name] &&
      hound_config[style_guide_name]["config_file"]
  end

  def load_file(file_path, file_type)
    config_file_content = commit.file_content(file_path)

    if config_file_content.present?
      send("parse_#{file_type}", config_file_content)
    else
      {}
    end
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
