module LinterHelper
  def build_style_guide(config = "config", build = build(:build))
    repo_config = double("RepoConfig", raw_for: config)
    described_class.new(
      repo_config: repo_config,
      build: build,
      repository_owner_name: "ralph",
    )
  end
end

RSpec.configure do |config|
  config.include LinterHelper
end
