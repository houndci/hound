class StyleGuide
  def initialize(override_config_content = nil)
    @override_config_content = override_config_content
  end

  def violations(file_content)
    investigate(parse_file_content(file_content))
  end

  private

  def investigate(parsed_file_content)
    team = Rubocop::Cop::Team.new(Rubocop::Cop::Cop.all, configuration)
    commissioner = Rubocop::Cop::Commissioner.new(team.cops)
    commissioner.investigate(parsed_file_content)
  end

  def parse_file_content(file_content)
    Rubocop::SourceParser.parse(file_content)
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
