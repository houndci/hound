require "app/services/resolve_config_conflicts"
require "app/models/config/parser_error"

describe ResolveConfigConflicts do
  describe "#call" do
    context "given a config with conflicting linters" do
      it "disables the first conflicted linter found" do
        config = { "eslint" => { "enabled" => true } }

        resolved_config = ResolveConfigConflicts.call(config)

        expect(resolved_config["jshint"]).to eq("enabled" => false)
        expect(resolved_config["eslint"]).to eq("enabled" => true)
      end
    end

    context "given a config with sass_lint enabled" do
      it "disables default Scss linter" do
        config = { "sass_lint" => { "enabled" => true } }

        resolved_config = ResolveConfigConflicts.call(config)

        expect(resolved_config["scss"]).to eq("enabled" => false)
        expect(resolved_config["sass_lint"]).to eq("enabled" => true)
      end
    end

    context "given nil config options" do
      it "raises Config::ParserError" do
        config = { "sass_lint" => nil }

        expect { ResolveConfigConflicts.call(config) }.to(
          raise_error(
            Config::ParserError,
            "sass_lint options in your .hound.yml are invalid"
          )
        )
      end
    end
  end
end
