class ScssConfigBuilder < MergeableConfigBuilder
  private

  def config_class
    Config::Scss
  end

  def linter_name
    "scss"
  end
end
