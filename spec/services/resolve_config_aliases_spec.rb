require "app/services/resolve_config_aliases"

describe ResolveConfigAliases do
  describe "#call" do
    context "when the config contains aliases" do
      it "renames them to the appropriate linter" do
        config = {
          "javascript" => { "enabled" => false },
          "ruby" => { "enabled" => true },
          "flog" => { "enabled" => false },
          "scss" => { "enabled" => true },
          "erblint" => { "enabled" => true },
        }

        actual = ResolveConfigAliases.call(config)

        expect(actual).to eql(
          "jshint" => { "enabled" => false },
          "rubocop" => { "enabled" => true },
          "flog" => { "enabled" => false },
          "scss_lint" => { "enabled" => true },
          "erb_lint" => { "enabled" => true },
        )
      end
    end
  end
end
