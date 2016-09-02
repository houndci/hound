class JshintConfigBuilder < MergeableConfigBuilder
  private

  def config_class
    Config::Jshint
  end

  def linter_name
    "jshint"
  end
end
