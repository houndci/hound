class StyleGuide
  def initialize(override_config_content = nil)
    @override_config_content = override_config_content
  end

  def violations(file)
    parsed_source = parse_source(file)
    team = Rubocop::Cop::Team.new(Rubocop::Cop::Cop.all, configuration)
    commissioner = Rubocop::Cop::Commissioner.new(team.cops, [])
    commissioner.investigate(parsed_source)
  end

  private

  def parse_source(file)
    Rubocop::SourceParser.parse(file.contents, file.filename)
  end

  def configuration
    config = Rubocop::ConfigLoader.configuration_from_file('config/rubocop.yml')

    if override_config
      config = Rubocop::Config.new(
        Rubocop::ConfigLoader.merge(config, override_config),
        ''
      )
    end

    config
  end

  def override_config
    if @override_config_content
      Rubocop::Config.new(YAML.load(@override_config_content))
    end
  end
end
