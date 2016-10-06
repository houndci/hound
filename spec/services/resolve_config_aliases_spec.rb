require "app/services/resolve_config_aliases"

describe ResolveConfigAliases do
  describe "#run" do
    context "when the config contains aliases" do
      it "renames them to the appropriate linter" do
        config = {
          "javascript" => { "enabled" => false },
          "ruby" => { "enabled" => false },
        }

        expect(ResolveConfigAliases.run(config).keys).
          to match_array(["jshint", "ruby"])
      end
    end
  end
end
