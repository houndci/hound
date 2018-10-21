# frozen_string_literal: true
class HoundConfig
  CONFIG_FILE = ".hound.yml"
  LINTERS = {
    Linter::Coffeelint => { default: true },
    Linter::Credo => { default: false },
    Linter::Eslint => { default: false },
    Linter::Flake8 => { default: false },
    Linter::Flog => { default: false },
    Linter::Golint => { default: true },
    Linter::Haml => { default: true },
    Linter::Jshint => { default: true },
    Linter::Reek => { default: false },
    Linter::Remark => { default: false },
    Linter::Rubocop => { default: true },
    Linter::SassLint => { default: false },
    Linter::ScssLint => { default: true },
    Linter::Shellcheck => { default: false },
    Linter::SlimLint => { default: false },
    Linter::Stylelint => { default: false },
    Linter::Swiftlint => { default: true },
    Linter::Tslint => { default: false },
  }.freeze

  attr_initialize [:commit!, :owner!]
  attr_reader :commit
  attr_private :owner

  def content
    @_content ||= default_config.deep_merge(merged_config)
  end

  def linter_enabled?(name)
    config = options_for(name)

    !!config["enabled"]
  end

  def linter_version(name)
    config = options_for(name)

    config["version"]
  end

  def fail_on_violations?
    !!content["fail_on_violations"]
  end

  private

  def default_config
    LINTERS.each.with_object({}) do |(linter_class, config), result|
      name = linter_class.name.demodulize.underscore
      result[name] = { "enabled" => config[:default] }
    end
  end

  def merged_config
    owner_config.deep_merge(resolved_conflicts_config)
  end

  def resolved_conflicts_config
    ResolveConfigConflicts.call(resolved_aliases_config)
  end

  def resolved_aliases_config
    ResolveConfigAliases.call(normalized_config)
  end

  def normalized_config
    NormalizeConfig.call(parsed_config)
  end

  def parsed_config
    parse(commit.file_content(CONFIG_FILE))
  end

  def parse(file_content)
    Config::Parser.yaml(file_content) || {}
  rescue Config::ParserError
    raise Config::ParserError, "#{CONFIG_FILE} format is invalid"
  end

  def options_for(name)
    content.fetch(name, {})
  end

  def owner_config
    owner.hound_config_content
  end
end
