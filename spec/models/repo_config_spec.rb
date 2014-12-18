require "attr_extras"
require "json"
require "fast_spec_helper"
require "app/models/repo_config"

describe RepoConfig do
  describe "#enabled_for?" do
    context "with invalid format in Hound config" do
      it "only returns true for ruby" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          hello world!
        EOS
        repo_config = RepoConfig.new(commit)

        expect(repo_config).to be_enabled_for("ruby")
        expect(repo_config).not_to be_enabled_for("coffee_script")
        expect(repo_config).not_to be_enabled_for("java_script")
      end
    end

    context "with invalid indentation in Hound config" do
      it "returns false for all style guides" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          coffee_script:
          enabled: true
        EOS
        repo_config = RepoConfig.new(commit)

        RepoConfig::STYLE_GUIDES.each do |style_guide_name|
          expect(repo_config).not_to be_enabled_for(style_guide_name)
        end
      end
    end

    context "when all style guides are disabled" do
      it "returns false for all style guides" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          ruby:
            enabled: false
          coffee_script:
            hello: world
          java_script:
            hello: world
        EOS
        repo_config = RepoConfig.new(commit)

        RepoConfig::STYLE_GUIDES.each do |style_guide_name|
          expect(repo_config).not_to be_enabled_for(style_guide_name)
        end
      end
    end

    context "when Ruby is enabled" do
      it "returns true for ruby" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          ruby:
            enabled: true
        EOS
        repo_config = RepoConfig.new(commit)

        expect(repo_config).to be_enabled_for("ruby")
      end
    end

    context "when CoffeeScript is enabled" do
      it "returns true for coffee_script" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          coffee_script:
            enabled: true
        EOS
        repo_config = RepoConfig.new(commit)

        expect(repo_config).to be_enabled_for("coffee_script")
      end
    end

    context "when JavaScript is enabled" do
      it "returns true for java_script" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          java_script:
            enabled: true
        EOS
        repo_config = RepoConfig.new(commit)

        expect(repo_config).to be_enabled_for("java_script")
      end
    end

    context "when SCSS is enabled" do
      it "returns true for scss" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          scss:
            enabled: true
        EOS
        repo_config = RepoConfig.new(commit)

        expect(repo_config).to be_enabled_for("scss")
      end
    end

    context "with legacy config file" do
      context "when no style guide is enabled" do
        it "only returns true for ruby" do
          commit = double("Commit", file_content: <<-EOS.strip_heredoc)
            LineLength:
              Max: 80
            DotPosition:
              EnforcedStyle: trailing
          EOS
          repo_config = RepoConfig.new(commit)

          expect(repo_config).to be_enabled_for("ruby")
          expect(repo_config).not_to be_enabled_for("coffee_script")
          expect(repo_config).not_to be_enabled_for("java_script")
        end
      end

      context "when CoffeeScript is enabled" do
        it "returns true for coffee_script and ruby" do
          commit = double("Commit", file_content: <<-EOS.strip_heredoc)
            CoffeeScript:
              Enabled: true
            LineLength:
              Max: 80
            DotPosition:
              EnforcedStyle: trailing
          EOS
          repo_config = RepoConfig.new(commit)

          expect(repo_config).to be_enabled_for("ruby")
          expect(repo_config).to be_enabled_for("coffee_script")
          expect(repo_config).not_to be_enabled_for("java_script")
        end
      end
    end

    context "when there is no Hound config file" do
      it "returns true for ruby" do
        commit = double("Commit", file_content: nil)
        config = RepoConfig.new(commit)

        expect(config).to be_enabled_for("ruby")
        expect(config).not_to be_enabled_for("coffee_script")
      end
    end
  end

  describe "#for" do
    context "when Ruby config file is specified" do
      it "returns parsed config" do
        config = config_for_file("config/rubocop.yml", <<-EOS.strip_heredoc)
          StringLiterals:
            EnforcedStyle: single_quotes

          LineLength:
            Max: 90
        EOS

        result = config.for("ruby")

        expect(result).to eq(
          "StringLiterals" => { "EnforcedStyle" => "single_quotes" },
          "LineLength" => { "Max" => 90 },
        )
      end
    end

    context "when CoffeeScript config file is specified" do
      it "returns parsed config" do
        config = config_for_file("coffeelint.json", <<-EOS.strip_heredoc)
          {
            "no_unnecessary_double_quotes": {
              "level": "error"
            }
          }
        EOS

        result = config.for("coffee_script")

        expect(result).to eq(
          "no_unnecessary_double_quotes" => { "level" => "error" }
        )
      end
    end

    context "when JavaScript config is specified" do
      context "and filename extension isn't json" do
        it "returns parsed config" do
          config = config_for_file(".jshintrc", <<-EOS.strip_heredoc)
            {
              "predef": ["hello"]
            }
          EOS

          result = config.for("java_script")

          expect(result).to eq("predef" => ["hello"])
        end
      end

      context "and contains invalid JSON format" do
        it "returns an empty config" do
          config = config_for_file("javascript.json", <<-EOS.strip_heredoc)
            {
              "predef": ["myGlobal",]
            }
          EOS

          result = config.for("java_script")

          expect(result).to eq({})
        end
      end
    end

    context "when there is no Hound config file" do
      it "returns empty config for all style guides" do
        commit = double("Commit", file_content: nil)
        config = RepoConfig.new(commit)

        RepoConfig::STYLE_GUIDES.each do |style_guide_name|
          expect(config.for(style_guide_name)).to eq({})
        end
      end
    end

    context "with legacy config file" do
      it "returns config for ruby" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          LineLength:
            Max: 80
          DotPosition:
            EnforcedStyle: trailing
        EOS
        repo_config = RepoConfig.new(commit)

        expect(repo_config.for("ruby")).to eq(
          "LineLength" => { "Max" => 80 },
          "DotPosition" => { "EnforcedStyle" => "trailing" },
        )
      end
    end

    describe "#jshint_ignore_file" do
      context "no specific configuration is present" do
        it "attempts to load a .jshintignore file" do
          ignored_files = <<-EOIGNORE.strip_heredoc
            app/assets/javascripts/*.js
            public/javascripts/**.js
          EOIGNORE

          hound_config = <<-EOS
            java_script:
              enabled: true
          EOS

          commit = stub_commit(
            hound_config: hound_config,
            ".jshintignore" => ignored_files
          )

          ignored_files = RepoConfig.new(commit).ignored_javascript_files

          expect(ignored_files).
            to eq ["app/assets/javascripts/*.js", "public/javascripts/**.js"]
        end
      end

      context "custom jshint ignore path provided" do
        it "uses the custom ignore file" do
          hound_config = <<-EOS
            java_script:
              enabled: true
              ignore_file: ".js_ignore"
          EOS

          ignored_files = <<-EOIGNORE.strip_heredoc
            app/assets/javascripts/*.js
            public/javascripts/**.js
          EOIGNORE

          commit = stub_commit(
            hound_config: hound_config,
            ".js_ignore" => ignored_files
          )

          ignored_files = RepoConfig.new(commit).ignored_javascript_files

          expect(ignored_files).
            to eq ["app/assets/javascripts/*.js", "public/javascripts/**.js"]
        end
      end
    end

    def stub_commit(configuration)
      commit = double("Commit")
      hound_config = configuration.delete(:hound_config)
      allow(commit).to receive(:file_content).
        with(RepoConfig::HOUND_CONFIG_FILE).and_return(hound_config)

      configuration.each do |filename, contents|
        allow(commit).to receive(:file_content).
          with(filename).and_return(contents)
      end

      commit
    end

    def config_for_file(file_path, content)
      hound_config = <<-EOS.strip_heredoc
        ruby:
          enabled: true
          config_file: config/rubocop.yml

        coffee_script:
          enabled: true
          config_file: coffeelint.json

        java_script:
          enabled: true
          config_file: #{file_path}
      EOS

      commit = stub_commit(
        hound_config: hound_config,
        "#{file_path}" => content
      )

      RepoConfig.new(commit)
    end
  end
end
