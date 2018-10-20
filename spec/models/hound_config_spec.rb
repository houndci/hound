Dir["app/models/linter/*.rb"].each { |f| require f }
require "app/models/config/parser"
require "app/services/normalize_config"
require "app/services/resolve_config_aliases"
require "app/services/resolve_config_conflicts"
require "app/models/hound_config"

describe HoundConfig do
  describe "#content" do
    it "returns the contents of .hound.yml, merged with the default config" do
      commit = stub_commit(
        ".hound.yml" => <<~EOS
          rubocop:
            config_file: config/rubocop.yml
        EOS
      )
      hound_config = build_hound_config(commit)

      expect(hound_config.content["rubocop"]).to eq(
        "enabled" => true,
        "config_file" => "config/rubocop.yml",
      )
    end
  end

  describe "#linter_enabled?" do
    context "for default linters" do
      it "returns true for all of them" do
        commit = stub_commit(".hound.yml" => "")
        hound_config = build_hound_config(commit)

        enabled_by_default = HoundConfig::LINTERS.
          select { |_, config| config[:default] }
        Hash(enabled_by_default).keys.each do |linter_name|
          expect(hound_config).
            to be_enabled_for(linter_name.name.demodulize.underscore)
        end
      end
    end

    context "when the linter is disabled" do
      it "returns false" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            rubocop:
              enabled: false
          EOS
        )
        hound_config = build_hound_config(commit)

        expect(hound_config).not_to be_enabled_for("rubocop")
      end
    end

    context "when linter is enabled" do
      it "returns true" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            eslint:
              enabled: true
          EOS
        )
        hound_config = build_hound_config(commit)

        expect(hound_config).to be_enabled_for("eslint")
      end
    end

    context "when provided linter name is an alias, and is disabled" do
      it "returns false" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            java_script:
              enabled: false
          EOS
        )
        hound_config = build_hound_config(commit)

        expect(hound_config).not_to be_enabled_for("jshint")
      end
    end

    context "when enabled linter conflicts with other enabled linter" do
      it "returns true for the provided linter" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            eslint:
              enabled: true
          EOS
        )
        hound_config = build_hound_config(commit)

        expect(hound_config).to be_enabled_for("eslint")
        expect(hound_config).not_to be_enabled_for("jshint")
      end
    end

    context "when provided an unsupported linter" do
      it "returns false" do
        commit = stub_commit(".hound.yml" => "")
        unsupported_linter = "some_random_linter"
        hound_config = build_hound_config(commit)

        expect(hound_config).not_to be_enabled_for(unsupported_linter)
      end
    end

    context "when the enabled key for linter is capitalized" do
      it "returns true" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            flake8:
              Enabled: true
          EOS
        )
        hound_config = build_hound_config(commit)

        expect(hound_config).to be_enabled_for("flake8")
      end
    end

    context "when the linter key should have underscores in it" do
      it "converts them and returns true" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            sass-lint:
              enabled: true
          EOS
        )
        hound_config = build_hound_config(commit)

        expect(hound_config).to be_enabled_for("sass_lint")
      end
    end

    context "when linter is enabled at the owner-level" do
      it "returns true" do
        owner_hound_config = <<~YAML
          flake8:
            enabled: true
        YAML
        repo_hound_config = ""
        commit = stub_commit(".hound.yml" => repo_hound_config)
        owner = owner_stub(owner_hound_config)
        hound_config = build_hound_config(commit, owner)

        expect(hound_config).to be_enabled_for("flake8")
      end
    end

    context "when linter enabled at owner-level but disabled at repo-level" do
      it "returns false" do
        owner_hound_config = <<~YAML
          flake8:
            enabled: true
        YAML
        repo_hound_config = <<~YAML
          flake8:
            enabled: false
        YAML
        commit = stub_commit(".hound.yml" => repo_hound_config)
        owner = owner_stub(owner_hound_config)
        hound_config = build_hound_config(commit, owner)

        expect(hound_config).not_to be_enabled_for("flake8")
      end
    end
  end

  describe "#linter_version" do
    context "when version is specified" do
      it "returns version" do
        commit = stub_commit(
          ".hound.yml" => <<~CONFIG
            rubocop:
              version: 1.2.3
          CONFIG
        )
        hound_config = build_hound_config(commit)

        version = hound_config.linter_version("rubocop")

        expect(version).to eq("1.2.3")
      end
    end

    context "when version is not specified" do
      it "returns nothing" do
        commit = stub_commit(
          ".hound.yml" => <<~CONFIG
            rubocop:
              enabled: true
          CONFIG
        )
        hound_config = build_hound_config(commit)

        version = hound_config.linter_version("rubocop")

        expect(version).to be_blank
      end
    end
  end

  describe "#fail_on_violations?" do
    context "when the setting is turned on" do
      it "returns true" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            fail_on_violations: true
          EOS
        )
        hound_config = build_hound_config(commit)

        expect(hound_config.fail_on_violations?).to eq true
      end
    end

    context "when the setting is turned off" do
      it "returns false" do
        commit = stub_commit(
          ".hound.yml" => <<~EOS
            fail_on_violations: false
          EOS
        )
        hound_config = build_hound_config(commit)

        expect(hound_config.fail_on_violations?).to eq false
      end
    end

    context "when the setting is unconfigured" do
      it "returns false" do
        commit = stub_commit(".hound.yml" => "")
        hound_config = build_hound_config(commit)

        expect(hound_config.fail_on_violations?).to eq false
      end
    end
  end

  def build_hound_config(commit, owner = owner_stub)
    HoundConfig.new(commit: commit, owner: owner)
  end

  def owner_stub(hound_config = "")
    config = YAML.safe_load(hound_config) || {}
    instance_double("Owner", hound_config_content: config)
  end

  def be_enabled_for(linter_name)
    be_linter_enabled(linter_name)
  end
end
