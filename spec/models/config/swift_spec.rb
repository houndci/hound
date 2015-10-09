require "spec_helper"
require "app/models/config/base"
require "app/models/config/swift"

describe Config::Swift do
  it_behaves_like "a service based linter" do
    let(:raw_config) do
      <<-EOS.strip_heredoc
        disabled_rules:
          - colon
      EOS
    end

    let(:hound_config_content) do
      {
        "swift" => {
          "enabled" => true,
          "config_file" => "config/swiftlint.yml",
        },
      }
    end
  end
end
