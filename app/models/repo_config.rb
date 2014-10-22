# Load and parse config files from GitHub repo
class RepoConfig
  FILE_TYPES = {
    "ruby" => "yaml",
    "java_script" => "json",
    "coffee_script" => "json",
  }
  HOUND_CONFIG_FILE = ".hound.yml"
  STYLE_GUIDES = %w(ruby coffee_script java_script)

  attr_reader :errors

  pattr_initialize :commit do
    @errors = []
  end

  def enabled_for?(style_guide_name)
    style_guide_name == "ruby" && legacy_config? ||
      enabled_in_config?(style_guide_name)
  end

  def for(style_guide_name)
    if style_guide_name == "ruby" && legacy_config?
      hound_config
    else
      config_file_path = config_path_for(style_guide_name)

      if config_file_path
        load_file(config_file_path, FILE_TYPES[style_guide_name])
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

  def validate
    @errors = invalid_style_guides.map do |style_guide|
      I18n.t(
        "invalid_config",
        config_file_name: config_path_for(style_guide)
      )
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
        content
      else
        {}
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

  def invalid_style_guides
    STYLE_GUIDES.select do |style_guide|
      enabled_for?(style_guide) && self.for(style_guide).empty?
    end
  end
end
