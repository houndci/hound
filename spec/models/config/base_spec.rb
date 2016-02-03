require "spec_helper"
require "app/models/config/base"
require "app/models/config/parser_error"
require "faraday"
require "yaml"

class Config::Test < Config::Base
  def serialize(content)
    ensure_correct_type(content).to_yaml
  end

  private

  def parse(file_content)
    file_content
  end
end

describe Config::Base do
  describe "#content" do
    context "when there is no config content for the given linter" do
      it "does not raise" do
        config = build_config(linter_name: "unconfigured_linter")

        expect { config.content }.not_to raise_error
      end
    end

    context "when there is no specified filepath" do
      it "returns a default value" do
        hound_config = double(
          "HoundConfig",
          commit: double("Commit"),
          content: {
            "test" => {},
          },
        )
        config = build_config(hound_config: hound_config)

        expect(config.content).to eq("{}")
      end
    end

    context "when the filepath is a url" do
      context "when url exists" do
        it "returns the content of the url" do
          hound_config = double(
            "HoundConfig",
            commit: double("Commit"),
            content: {
              "test" => {
                "config_file" => "http://example.com/rubocop.yml",
              },
            },
          )
          response = <<-EOS.strip_heredoc
            LineLength:
              Max: 90
          EOS
          stub_request(
            :get,
            "http://example.com/rubocop.yml",
          ).to_return(
            status: 200,
            body: response,
          )
          config = build_config(hound_config: hound_config)

          expect(config.content).to eq response
        end
      end

      context "when the url does not exist" do
        it "raises an exception" do
          hound_config = double(
            "HoundConfig",
            commit: double("Commit"),
            content: {
              "test" => {
                "config_file" => "http://example.com/rubocop.yml",
              },
            },
          )
          stub_request(
            :get,
            "http://example.com/rubocop.yml",
          ).to_return(
            status: 404,
            body: "Could not find resource",
          )
          config = build_config(hound_config: hound_config)

          expect { config.content }.to raise_error do |exception|
            expect(exception).to be_a Config::ParserError
            expect(exception.message).to eq "404 Could not find resource"
          end
        end
      end
    end

    context "when `parse` is not defined" do
      it "raises an exception" do
        hound_config = double(
          "HoundConfig",
          commit: double("Commit", file_content: ""),
          content: {
            "linter" => { "config_file" => "config-file.txt" },
          },
        )
        config = Config::Base.new(hound_config, "linter")

        expect { config.content }.to raise_error(
          AttrExtras::MethodNotImplementedError,
          "Implement a 'parse(file_content)' method",
        )
      end
    end
  end

  describe "#excluded_files" do
    it "returns an empty array" do
      config = build_config

      expect(config.excluded_files).to eq []
    end
  end

  describe "#linter_names" do
    it "returns a list of names the linter is accessible under" do
      config = build_config(linter_name: "test")

      expect(config.linter_names).to eq ["test"]
    end
  end

  def build_config(hound_config: build_hound_config, linter_name: "test")
    Config::Test.new(hound_config, linter_name)
  end

  def build_hound_config
    double(
      "HoundConfig",
      commit: double("Commit", file_content: ""),
      content: {
        "test" => { "config_file" => "config-file.txt" },
      },
    )
  end
end
