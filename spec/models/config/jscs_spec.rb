require "spec_helper"
require "app/models/config/base"
require "app/models/config/jscs"

describe Config::Jscs do
  it_behaves_like "a service based linter" do
    let(:raw_config) do
      <<-EOS.strip_heredoc
        { "disallowKeywordsInComments": true }
      EOS
    end

    let(:hound_config_content) do
      {
        "jscs" => {
          "enabled" => true,
          "config_file" => "config/.jscsrc",
        },
      }
    end
  end
end
