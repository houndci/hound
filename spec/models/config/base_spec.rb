require "spec_helper"
require "app/models/config/base"
require "app/models/config/parser_error"
require "faraday"

class Config::Test < Config::Base
  private

  def parse(file_content)
    file_content
  end
end

describe Config::Base do
  describe "#content" do
    context "when there is no config content for the given linter" do
      it "does not raise" do
        commit = double("Commit")
        hound_config = double(
          "HoundConfig",
          commit: commit,
          content: {},
        )
        config = Config::Test.new(hound_config, "unconfigured_linter")

        expect { config.content }.not_to raise_error
      end
    end

    context "when there is no specified filepath" do
      it "returns a default value" do
        commit = double("Commit")
        hound_config = double(
          "HoundConfig",
          commit: commit,
          content: {
            "linter" => {},
          },
        )
        config = Config::Test.new(hound_config, "linter")

        expect(config.content).to eq("{}")
      end
    end

    context "when the filepath is a url" do
      context "when url exists" do
        it "returns the content of the url" do
          commit = double("Commit")
          hound_config = double(
            "HoundConfig",
            commit: commit,
            content: {
              "linter" => {
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
          config = Config::Test.new(hound_config, "linter")

          expect(config.content).to eq response
        end
      end

      context "when the url does not exist" do
        it "raises an exception" do
          commit = double("Commit")
          hound_config = double(
            "HoundConfig",
            commit: commit,
            content: {
              "linter" => {
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
          config = Config::Test.new(hound_config, "linter")

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
          commit: double("Commit", file_content: "config"),
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
      config = Config::Test.new(double, double)

      expect(config.excluded_files).to eq []
    end
  end
end
