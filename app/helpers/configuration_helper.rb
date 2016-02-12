module ConfigurationHelper
  def ruby_config_url
    config_url("houndci/hound", "config/style_guides/ruby.yml")
  end

  def coffeescript_config_url
    config_url("houndci/hound", "config/style_guides/coffeescript.json")
  end

  def javascript_config_url
    config_url("houndci/jshint", "config/.jshintrc")
  end

  def javascript_ignore_url
    config_url("houndci/hound", "config/style_guides/.jshintignore")
  end

  def jscs_config_url
    config_url("thoughtbot/guides", "style/javascript/.jscsrc")
  end

  def eslint_config_url
    config_url("houndci/eslint", "config/.eslintrc")
  end

  def scss_config_url
    config_url("houndci/scss", "config/default.yml")
  end

  def haml_config_url
    config_url("houndci/hound", "config/style_guides/haml.yml")
  end

  def swift_config_url
    config_url("houndci/swift", "config/default.yml")
  end

  private

  def config_url(slug, config_file)
    "https://raw.githubusercontent.com/#{slug}/master/#{config_file}"
  end
end
