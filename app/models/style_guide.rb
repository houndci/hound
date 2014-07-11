class StyleGuide
  def initialize(override_config_content = nil)
    @override_config_content = override_config_content
  end

  def violations(file)
    if ignored_file?(file)
      []
    else
      parsed_source = parse_source(file)
      cops = RuboCop::Cop::Cop.all
      team = RuboCop::Cop::Team.new(cops, config, rubocop_options)
      team.inspect_file(parsed_source)
    end
  end

  private

  def ignored_file?(file)
    !file.ruby? || file.removed? || excluded_file?(file)
  end

  def excluded_file?(file)
    config.file_to_exclude?(file.filename)
  end

  def parse_source(file)
    RuboCop::ProcessedSource.new(file.contents)
  end

  def config
    if @config.nil?
      config_file = "config/rubocop.yml"
      config = RuboCop::ConfigLoader.configuration_from_file(config_file)
      combined_config = RuboCop::ConfigLoader.merge(config, override_config)
      @config = RuboCop::Config.new(combined_config, "")
    end

    @config
  end

  def rubocop_options
    if config["ShowCopNames"]
      { debug: true }
    end
  end

  def override_config
    if @override_config_content
      config_content = YAML.load(@override_config_content)
      override_config = RuboCop::Config.new(config_content, "")
      override_config.add_missing_namespaces
      override_config.make_excludes_absolute
      override_config
    else
      {}
    end
  end
end
