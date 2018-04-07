require "spec_helper"
require "app/models/config/base"
require "app/models/config/golint"
require "app/models/config/parser"
require "app/models/config_content"
require "app/models/missing_owner"

describe Config::Golint do
  describe "#content" do
    it "returns an empty hash" do
      config_content = instance_double("ConfigContent", load: {})
      content = { golint: { enabled: true } }
      raw_content = <<~EOS
        go:
          enabled: true
      EOS
      commit = instance_double("Commit", file_content: raw_content)
      hound_config = instance_double(
        "HoundConfig",
        commit: commit,
        content: content,
      )
      owner = instance_double("Owner", config_content: {})
      allow(ConfigContent).to receive(:new).and_return(config_content)
      config = Config::Golint.new(hound_config, owner: owner)

      expect(config.content).to eq({})
    end
  end
end
