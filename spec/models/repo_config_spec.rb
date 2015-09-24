require "attr_extras"
require "json"
require "rails_helper"
require "app/models/repo_config"

describe RepoConfig do
  describe "#enabled_for?" do
    context "with invalid config" do
      it "returns true for all default languages" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          hello world!
        EOS
        repo_config = RepoConfig.new(commit)

        default_languages.each do |language|
          expect(repo_config).to be_enabled_for(language)
        end
      end

      it "returns false for all beta languages" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          hello world!
        EOS
        repo_config = RepoConfig.new(commit)

        beta_languages.each do |language|
          expect(repo_config).not_to be_enabled_for(language)
        end
      end
    end

    context "when all languages are enabled" do
      it "returns true for all languages" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          ruby:
            enabled: true
          coffeescript:
            enabled: true
          javascript:
            enabled: true
          scss:
            enabled: true
          haml:
            enabled: true
          go:
            enabled: true
          python:
            enabled: true
          swift:
            enabled: true
        EOS
        repo_config = RepoConfig.new(commit)

        all_languages.each do |language|
          expect(repo_config).to be_enabled_for(language)
        end
      end
    end

    context "when all languages are disabled using lowercase" do
      it "returns false for all languages" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          ruby:
            enabled: false
          coffeescript:
            enabled: false
          javascript:
            enabled: false
          scss:
            enabled: false
          haml:
            enabled: false
          go:
            enabled: false
        EOS
        repo_config = RepoConfig.new(commit)

        all_languages.each do |language|
          expect(repo_config).not_to be_enabled_for(language)
        end
      end
    end

    context "with legacy config file" do
      context "when no language is enabled or disabled" do
        it "returns true for all default languages" do
          commit = double("Commit", file_content: <<-EOS.strip_heredoc)
            LineLength:
              Max: 80
            DotPosition:
              EnforcedStyle: trailing
          EOS
          repo_config = RepoConfig.new(commit)

          default_languages.each do |language|
            expect(repo_config).to be_enabled_for(language)
          end
        end

        it "returns false for all beta languages" do
          commit = double("Commit", file_content: <<-EOS.strip_heredoc)
            LineLength:
              Max: 80
            DotPosition:
              EnforcedStyle: trailing
          EOS
          repo_config = RepoConfig.new(commit)

          beta_languages.each do |language|
            expect(repo_config).not_to be_enabled_for(language)
          end
        end
      end

      context "when all languages are enabled" do
        it "returns true for all languages" do
          commit = double("Commit", file_content: <<-EOS.strip_heredoc)
            LineLength:
              Max: 80
            DotPosition:
              EnforcedStyle: trailing
            Ruby:
              Enabled: true
            JavaScript:
              Enabled: true
            CoffeeScript:
              Enabled: true
            SCSS:
              Enabled: true
            Haml:
              Enabled: true
            Go:
              Enabled: true
            Python:
              Enabled: true
            Swift:
              Enabled: true
          EOS
          repo_config = RepoConfig.new(commit)

          all_languages.each do |language|
            expect(repo_config).to be_enabled_for(language)
          end
        end
      end

      context "when all languages are disabled using uppercase" do
        it "returns false for all languages" do
          commit = double("Commit", file_content: <<-EOS.strip_heredoc)
            LineLength:
              Max: 80
            DotPosition:
              EnforcedStyle: trailing
            Ruby:
              Enabled: false
            JavaScript:
              Enabled: false
            CoffeeScript:
              Enabled: false
            Scss:
              Enabled: false
            Haml:
              Enabled: false
            Go:
              Enabled: false
          EOS
          repo_config = RepoConfig.new(commit)

          all_languages.each do |language|
            expect(repo_config).not_to be_enabled_for(language)
          end
        end
      end
    end

    context "when there is no Hound config file" do
      it "returns true for all default languages" do
        commit = double("Commit", file_content: nil)
        repo_config = RepoConfig.new(commit)

        default_languages.each do |language|
          expect(repo_config).to be_enabled_for(language)
        end
      end

      it "returns false for all beta languages" do
        commit = double("Commit", file_content: nil)
        repo_config = RepoConfig.new(commit)

        beta_languages.each do |language|
          expect(repo_config).not_to be_enabled_for(language)
        end
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

      context "with a list of inherit_from files" do
        it "returns violations" do
          hound_config = <<-EOS.strip_heredoc
            ruby:
              enabled: true
              config_file: .rubocop.yml
          EOS

          rubocop = <<-EOS.strip_heredoc
            inherit_from:
              - config/base.yml
              - config/overrides.yml
            Style/Encoding:
              Enabled: true
          EOS

          base = <<-EOS.strip_heredoc
            LineLength:
              Max: 40
          EOS

          overrides = <<-EOS.strip_heredoc
            Style/HashSyntax:
              EnforcedStyle: hash_rockets
            Style/Encoding:
              Enabled: false
          EOS

          commit = stub_commit(
            hound_config: hound_config,
            ".rubocop.yml" => rubocop,
            "config/base.yml" => base,
            "config/overrides.yml" => overrides
          )

          config = RepoConfig.new(commit)

          result = config.for("ruby")

          expect(result).to eq(
            "Style/HashSyntax" => { "EnforcedStyle" => "hash_rockets" },
            "LineLength" => { "Max" => 40 },
            "Style/Encoding" => { "Enabled" => true }
          )
        end
      end

      context "with a single inherit_from entry" do
        it "returns violations" do
          hound_config = <<-EOS.strip_heredoc
            ruby:
              config_file: .rubocop.yml
          EOS
          rubocop = <<-EOS.strip_heredoc
            inherit_from: config/base.yml

            Style/Encoding:
              Enabled: true
          EOS
          base = <<-EOS.strip_heredoc
            LineLength:
              Max: 40
          EOS
          commit = stub_commit(
            hound_config: hound_config,
            ".rubocop.yml" => rubocop,
            "config/base.yml" => base,
          )
          config = RepoConfig.new(commit)

          result = config.for("ruby")

          expect(result).to eq(
            "LineLength" => { "Max" => 40 },
            "Style/Encoding" => { "Enabled" => true },
          )
        end
      end

      context "with bad syntax" do
        it "raises RepoConfig::ParserError error" do
          config = config_for_file("config/rubocop.yml", <<-EOS.strip_heredoc)
            StringLiterals: !ruby/object
              ;foo:
          EOS

          expect { config.for("ruby") }.to raise_error do |error|
            expect(error).to be_a RepoConfig::ParserError
            expect(error.filename).to eq "config/rubocop.yml"
          end
        end
      end

      context "with unsafe yaml" do
        it "raises error" do
          config = config_for_file("config/rubocop.yml", <<-EOS.strip_heredoc)
            StringLiterals: !ruby/object
              foo:
          EOS

          expect { config.for("ruby") }.
            to raise_error RepoConfig::ParserError, /Psych::DisallowedClass/
        end
      end

      context "with ruby regex in yaml" do
        it "does not raise an error" do
          config = config_for_file("config/rubocop.yml", <<-EOS.strip_heredoc)
            WordRegex: !ruby/regexp /\A[\p{Word}]+\z/
          EOS

          expect { config.for("ruby") }.not_to raise_error
        end
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

        result = config.for("coffeescript")

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

          result = config.for("javascript")

          expect(result).to eq("predef" => ["hello"])
        end
      end

      context "and contains invalid JSON format" do
        it "raises an error" do
          config = config_for_file("javascript.json", <<-EOS.strip_heredoc)
            {
              "predef": ["myGlobal",]
            }
          EOS

          expect { config.for("javascript") }.
            to raise_error(RepoConfig::ParserError)
        end
      end
    end

    context "with SCSS config" do
      it "returns parsed config" do
        config_text = <<-EOS.strip_heredoc
          linters:
            StringQuotes:
              enabled: true
              style: double_quotes
        EOS
        config = config_for_file(".scss.yml", config_text)

        result = config.for("scss")

        expect(result).to eq(
          "linters" => {
            "StringQuotes" => {
              "enabled" => true,
              "style" => "double_quotes",
            }
          }
        )
      end
    end

    context "with HAML config" do
      it "returns parsed config" do
        config_text = <<-EOS.strip_heredoc
          linters:
            ImplicitDiv:
              enabled: true
        EOS
        config = config_for_file(".haml.yml", config_text)

        result = config.for("haml")

        expect(result).to eq(
          "linters" => {
            "ImplicitDiv" => {
              "enabled" => true
            }
          }
        )
      end
    end

    context "when there is no Hound config file" do
      it "returns empty config for all style guides" do
        commit = double("Commit", file_content: nil)
        config = RepoConfig.new(commit)

        all_languages.each do |language|
          expect(config.for(language)).to eq({})
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
      it "return default paths" do
        commit = stub_commit(hound_config: "")
        ignored_files = RepoConfig.new(commit).ignored_javascript_files

        expect(ignored_files).to eq ["vendor/*"]
      end

      context "no specific configuration is present" do
        it "attempts to load a .jshintignore file" do
          ignored_files = <<-EOIGNORE.strip_heredoc
            app/assets/javascripts/*.js
            public/javascripts/**.js
          EOIGNORE

          hound_config = <<-EOS
            javascript:
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
            javascript:
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
  end

  describe "#raw_for" do
    context "when Ruby config file is specified" do
      it "returns raw config" do
        raw_config = <<-CONFIG
          StringLiterals:
            EnforcedStyle: single_quotes

          LineLength:
            Max: 90
        CONFIG
        config = config_for_file("config/rubocop.yml", raw_config)

        result = config.raw_for("ruby")

        expect(result).to eq raw_config
      end
    end
  end

  describe "#fail_on_violations?" do
    context "when fail on violations is not present" do
      it "returns false" do
        commit = double("Commit", file_content: "")
        repo_config = RepoConfig.new(commit)

        expect(repo_config).not_to be_fail_on_violations
      end
    end

    context "when fail on violations is disabled" do
      it "returns false" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          fail_on_violations: false
        EOS
        repo_config = RepoConfig.new(commit)

        expect(repo_config).not_to be_fail_on_violations
      end
    end

    context "when fail on violations is enabled" do
      it "returns true" do
        commit = double("Commit", file_content: <<-EOS.strip_heredoc)
          fail_on_violations: true
        EOS
        repo_config = RepoConfig.new(commit)

        expect(repo_config).to be_fail_on_violations
      end
    end
  end

  it "converts legacy coffee_script key to coffeescript" do
    commit = double("Commit", file_content: <<-EOS.strip_heredoc)
      coffee_script:
        enabled: false
    EOS
    repo_config = RepoConfig.new(commit)

    expect(repo_config).not_to be_enabled_for("coffeescript")
  end

  it "converts legacy java_script key to javascript" do
    commit = double("Commit", file_content: <<-EOS.strip_heredoc)
      java_script:
        enabled: false
    EOS
    repo_config = RepoConfig.new(commit)

    expect(repo_config).not_to be_enabled_for("javascript")
  end

  def all_languages
    RepoConfig::LANGUAGES
  end

  def default_languages
    all_languages - beta_languages
  end

  def beta_languages
    RepoConfig::BETA_LANGUAGES
  end

  def config_for_file(file_path, content)
    hound_config = <<-EOS.strip_heredoc
      ruby:
        enabled: true
        config_file: config/rubocop.yml

      coffeescript:
        enabled: true
        config_file: coffeelint.json

      javascript:
        enabled: true
        config_file: #{file_path}

      scss:
        enabled: true
        config_file: #{file_path}

      haml:
        enabled: true
        config_file: #{file_path}
    EOS

    commit = stub_commit(
      hound_config: hound_config,
      "#{file_path}" => content
    )

    RepoConfig.new(commit)
  end

  def stub_commit(configuration)
    commit = double("Commit")
    hound_config = configuration.delete(:hound_config)
    allow(commit).to receive(:file_content)
    allow(commit).to receive(:file_content).
      with(RepoConfig::HOUND_CONFIG).and_return(hound_config)

    configuration.each do |filename, contents|
      allow(commit).to receive(:file_content).
        with(filename).and_return(contents)
    end

    commit
  end
end
