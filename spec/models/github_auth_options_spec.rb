require "spec_helper"
require "app/models/github_auth_options"
require "rack"

describe GithubAuthOptions do
  describe "#to_hash" do
    context "when request access param is full" do
      it "returns expected scopes, sorted by name" do
        env = { Rack::QUERY_STRING => "access=full", "rack.input" => "whatevs" }
        options = GithubAuthOptions.new(env)

        options_as_hash = options.to_hash

        expect(options_as_hash[:scope]).to eq "repo,user:email"
      end
    end

    context "when request access param is not full" do
      it "returns expected scope" do
        env = { "rack.input" => "whatevs" }
        options = GithubAuthOptions.new(env)

        options_as_hash = options.to_hash

        expect(options_as_hash[:scope]).to eq "user:email"
      end
    end
  end
end
