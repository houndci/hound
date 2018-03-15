# frozen_string_literal: true

require "spec_helper"
require "app/models/config_content"
require "app/models/config_content/remote"
require "faraday"

class ConfigContent
  RSpec.describe Remote do
    describe "#load" do
      context "successfully" do
        it "is a hash of the remote config file" do
          url = "https://example.com/rubocop.yml"
          response = <<~EOS
            LineLength:
              Max: 90
          EOS
          stub_request(:get, url).to_return(status: 200, body: response)

          expect(Remote.new(url).load). to eq(response)
        end
      end

      context "when there is an issue with the remote config file" do
        it "raises an exception" do
          url = "https://example.com/rubocop.yml"
          stub_request(:get, url).to_return(
            status: 404,
            body: "Could not find resource",
          )

          expect do
            Remote.new(url).load
          end.to raise_error(
            ConfigContent::ContentError,
            "404 Could not find resource",
          )
        end
      end
    end
  end
end
