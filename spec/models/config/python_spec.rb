require "spec_helper"
require "app/models/config/base"
require "app/models/config/python"

describe Config::Python do
  it_behaves_like "a service based linter" do
    let(:raw_config) do
      <<-EOS.strip_heredoc
        [flake8]
        max-line-length = 160
      EOS
    end

    let(:hound_config_content) do
      {
        "python" => {
          "enabled" => true,
          "config_file" => "config/python.ini",
        },
      }
    end
  end

  describe "#content" do
    context "when there is no config content for the given linter" do
      it "returns the empty string" do
        hound_config = double(
          "HoundConfig",
          commit: double("Commit"),
          content: {},
        )
        config = Config::Python.new(hound_config, "unconfigured_linter")

        expect(config.content).to eq ""
      end
    end
  end
end
