require "spec_helper"
require "app/models/config/base"
require "app/models/config/jshint"

describe Config::Jshint do
  it_behaves_like "a service based linter" do
    let(:raw_config) do
      <<-EOS.strip_heredoc
        {
          "maxlen": 80,
        }
      EOS
    end

    let(:hound_config_content) do
      {
        "jshint" => {
          "enabled" => true,
          "config_file" => "config/.jshintrc",
        },
      }
    end
  end
end
