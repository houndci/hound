module ConfigurationHelper
  def ruby_config_url
    config_url("bbatsov/rubocop", "config/enabled.yml")
  end

  def javascript_config_url
    config_url("houndci/jshint", "config/.jshintrc")
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

  private

  def config_url(slug, config_file)
    "https://raw.githubusercontent.com/#{slug}/master/#{config_file}"
  end
end
