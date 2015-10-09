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
end
