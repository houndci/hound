require "app/services/resolve_config_conflicts"

describe ResolveConfigConflicts do
  describe "#run" do
    context "given a config with conflicting linters" do
      it "disables the first conflicted linter found" do
        config = { "eslint" => { "enabled" => true } }

        resolved_config = ResolveConfigConflicts.run(config)

        expect(resolved_config["jshint"]).to eq("enabled" => false)
      end
    end
  end
end
