require "spec_helper"
require "app/models/config/base"
require "app/models/config/scss"

describe Config::Scss do
  it_behaves_like "a service based linter" do
    let(:raw_config) do
      <<-EOS.strip_heredoc
        linters:
          BangFormat:
            enabled: true
            space_before_bang: true
            space_after_bang: false
      EOS
    end

    let(:hound_config_content) do
      {
        "scss" => {
          "enabled" => true,
          "config_file" => "config/scss.yml",
        },
      }
    end
  end
end
