require "app/services/normalize_config"

describe NormalizeConfig do
  describe "#run" do
    context "given a hash with keys containing capital letters" do
      it "downcases the keys" do
        config = { "Ruby" => { "Enabled" => true } }

        expect(NormalizeConfig.run(config)).to eq(
          "ruby" => { "enabled" => true }
        )
      end
    end
  end
end
