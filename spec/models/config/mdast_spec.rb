require "spec_helper"
require "app/models/config/base"
require "app/models/config/mdast"

describe Config::Mdast do
  it_behaves_like "a service based linter" do
    let(:raw_config) do
      <<-EOS.strip_heredoc
        {
          "heading-style": "setext"
        }
      EOS
    end

    let(:hound_config_content) do
      {
        "mdast" => {
          "enabled" => true,
          "config_file" => "config/.mdastrc",
        },
      }
    end
  end
end
