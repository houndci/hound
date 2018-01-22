# frozen_string_literal: true
class HoundConfig
  LINTERS = {
    Linter::CoffeeScript => { default: true },
    Linter::Credo => { default: false },
    Linter::Eslint => { default: false },
    Linter::Flog => { default: false },
    Linter::Go => { default: true },
    Linter::Haml => { default: true },
    Linter::Jshint => { default: true },
    Linter::Python => { default: false },
    Linter::Reek => { default: false },
    Linter::Remark => { default: false },
    Linter::Ruby => { default: true },
    Linter::SassLint => { default: false },
    Linter::Scss => { default: true },
    Linter::SlimLint => { default: false },
    Linter::Stylelint => { default: false },
    Linter::Swift => { default: true },
    Linter::Tslint => { default: false },
  }.freeze
  CONFIG_FILE = ".hound.yml"

  attr_reader_initialize :commit

  def content
    @_content ||= default_config.deep_merge(resolved_conflicts_config)
  end

  def linter_enabled?(name)
    key = name.downcase
    config = options_for(key)

    !!config["enabled"]
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

  def resolved_aliases_config
    ResolveConfigAliases.call(normalized_config)
  end

  def normalized_config
    NormalizeConfig.call(parsed_config)
  end

  def resolved_conflicts_config
    ResolveConfigConflicts.call(resolved_aliases_config)
  end

  def parsed_config
    parse(commit.file_content(CONFIG_FILE))
  end

  def parse(file_content)
    Config::Parser.yaml(file_content) || {}
  end

  def options_for(name)
    content.fetch(name, {})
  end
end
