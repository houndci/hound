require "spec_helper"
require "app/models/config_content"
require "app/models/config_content/remote"
require "app/models/config/parser"
require "faraday"
require "json"

RSpec.describe ConfigContent do
  describe "#load" do
    context "when the file path exists" do
      it "is a hash of the config file's contents" do
        file_path = "config-file.txt"
        parser = ->(_raw_content) { { "LineLength" => { "Max" => 90 } } }
        raw_content = <<~EOS
          LineLength:
            Max: 90
        EOS
        commit = instance_double("Commit", file_content: raw_content)

        expect(ConfigContent.new(
          commit: commit,
          file_path: file_path,
          parser: parser,
        ).load).to eq("LineLength" => { "Max" => 90 })
      end
    end

    context "when the file path is a URL" do
      it "is a hash of the remote config file's contents" do
        commit = instance_double("Commit")
        file_path = "https://example.com/rubocop.yml"
        parser = ->(_raw_content) { { "LineLength" => { "Max" => 90 } } }
        raw_content = <<~EOS
          LineLength:
            Max: 90
        EOS
        remote = instance_double("ConfigContent::Remote", load: raw_content)
        allow(ConfigContent::Remote).to receive(:new).and_return(remote)

        expect(ConfigContent.new(
          commit: commit,
          file_path: file_path,
          parser: parser,
        ).load).to eq("LineLength" => { "Max" => 90 })
      end
    end

    context "when there is no file path" do
      it "is an empty hash" do
        commit = instance_double("Commit")
        parser = ->(_) {}
        config_content = ConfigContent.new(
          commit: commit,
          file_path: nil,
          parser: parser,
        )

        expect(config_content.load).to eq({})
      end
    end

    context "when the config is invalid" do
      it "raises an exception" do
        file_path = "config-file.txt"
        parser = ->(content) { Config::Parser.yaml(content) }
        raw_content = <<~EOS
          foo: bar
            baz: qux
        EOS
        commit = instance_double("Commit", file_content: raw_content)
        allow(Config::Parser).to receive(:yaml).and_raise(
          Psych::SyntaxError.new(
            nil,
            2,
            6,
            0,
            "mapping values are not allowed in this context",
            nil,
          ),
        )

        expect do
          ConfigContent.new(
            commit: commit,
            file_path: file_path,
            parser: parser,
          ).load
        end.to raise_error(ConfigContent::ContentError)
      end
    end

    context "when the parsed config is not a hash" do
      it "raises an exception" do
        file_path = "config-file.txt"
        parser = ->(_raw_content) { "" }
        raw_content = ""
        commit = instance_double("Commit", file_content: raw_content)

        expect do
          ConfigContent.new(
            commit: commit,
            file_path: file_path,
            parser: parser,
          ).load
        end.to raise_error(
          ConfigContent::ContentError,
          %{"config-file.txt" must be a Hash},
        )
      end
    end
  end
end
