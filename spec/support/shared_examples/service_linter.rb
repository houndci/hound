require "app/models/config/parser"

shared_examples "a service based linter" do
  describe "#content" do
    it "returns the content from GitHub as a in its raw format" do
      linter_name = described_class.name.demodulize.underscore
      config_file = hound_config_content[linter_name]["config_file"]
      commit = stubbed_commit(
        config_file => raw_config,
      )
      hound_config = double(
        "HoundConfig",
        commit: commit,
        content: hound_config_content,
      )
      config = described_class.new(hound_config, linter_name)

      expect(config.content).to eq(raw_config)
    end
  end
end
