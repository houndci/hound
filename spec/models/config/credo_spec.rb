require "spec_helper"
require "app/models/config/base"
require "app/models/config/credo"
require "app/models/config/parser"
require "app/models/config/serializer"

describe Config::Credo do
  describe "#content" do
    it "returns the raw string" do
      commit = stubbed_commit(".credo.exs" => raw_config)
      config = build_config(commit)

      expect(config.content).to eq raw_config
    end
  end

  describe "#serialize" do
    it "returns the raw content string" do
      commit = stubbed_commit(".credo.exs" => raw_config)
      config = build_config(commit)

      expect(config.serialize).to eq raw_config
    end
  end

  def build_config(commit)
    hound_config = double(
      "HoundConfig",
      commit: commit,
      content: {
        "credo" => { "config_file" => ".credo.exs" },
      },
    )

    Config::Credo.new(hound_config)
  end

  def raw_config
    <<-EOS.strip_heredoc
        %{
          configs: [
            %{
              name: "default",
              files: %{
                included: ["lib/", "src/", "web/", "apps/"],
                excluded: [],
              },
            }
          ]
        }
    EOS
  end
end
