# frozen_string_literal: true

module ConfigurationHelper
  def rubocop_config_url
    config_url("bbatsov/rubocop", "config/enabled.yml")
  end

  def eslint_config_url
    config_url("houndci/linters", "config/eslintrc")
  end

  def scss_config_url
    config_url("houndci/linters", "config/scss.yml")
  end

  def haml_config_url
    config_url("houndci/linters", "config/haml.yml")
  end

  def swift_config_url
    config_url("houndci/swift", "config/default.yml")
  end

  def tslint_config_url
    config_url("houndci/linters", "config/tslint.json")
  end

  def sass_lint_config_url
    config_url("sasstools/sass-lint", "lib/config/sass-lint.yml")
  end

  private

  def config_url(slug, config_file)
    "https://raw.githubusercontent.com/#{slug}/master/#{config_file}"
  end
end
