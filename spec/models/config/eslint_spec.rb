require "spec_helper"
require "app/models/config/base"
require "app/models/config/eslint"

describe Config::Eslint do
  it_behaves_like "a service based linter" do
    let(:raw_config) do
      <<-EOS.strip_heredoc
        rules:
            quotes: [2, "double"]
      EOS
    end

    let(:hound_config_content) do
      {
        "eslint" => {
          "enabled" => true,
          "config_file" => "config/.eslintrc",
        },
      }
    end
  end
end
