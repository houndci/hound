# frozen_string_literal: true
class HoundConfig
  LINTERS = [
    Linter::CoffeeScript,
    Linter::Credo,
    Linter::Eslint,
    Linter::Flog,
    Linter::Go,
    Linter::Haml,
    Linter::Jshint,
    Linter::Remark,
    Linter::Python,
    Linter::Reek,
    Linter::Ruby,
    Linter::Scss,
    Linter::Swift,
  ].freeze
  LINTER_NAMES = LINTERS.map { |klass| klass.name.demodulize.underscore }.freeze
  BETA_LINTERS = %w(
    credo
    eslint
    flog
    reek
    remark
    python
    tslint
  ).freeze
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
    LINTER_NAMES.each.with_object({}) do |name, config|
      config[name] = { "enabled" => !BETA_LINTERS.include?(name) }
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
