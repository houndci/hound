require "rails_helper"

describe LinterConfigsController do
  context "requesting ruby" do
    it "returns the merged RuboCop config" do
      user = create(:user)
      stub_sign_in(user)
      our_config = {
        "Style/OptionHash" => {
          "Enabled" => true,
        },
      }
      hound_yaml = <<-HOUND.strip_heredoc
        ruby:
          enabled: true
          config_file: ruby.yml
      HOUND
      stub_repo_request("thoughtbot/hound", user.token)
      stub_encoded_contents_request(
        sha: "master",
        repo_name: "thoughtbot/hound",
        file: ".hound.yml",
        body: hound_yaml,
        token: user.token,
      )
      stub_encoded_contents_request(
        sha: "master",
        repo_name: "thoughtbot/hound",
        file: "ruby.yml",
        body: YAML.dump(our_config),
        token: user.token,
      )

      get :show, owner: "thoughtbot", repo: "hound", linter: "ruby"

      config = YAML.load(response.body)
      expect(config["Style/StringLiterals"]).to match(
        hash_including(
          "EnforcedStyle" => "double_quotes",
          "Enabled" => true,
        ),
      )
      expect(config["Style/OptionHash"]).to match(
        hash_including(
          "Enabled" => true,
        ),
      )
      expect(config["Metrics/LineLength"]).to match(
        hash_including(
          "Max" => 80,
        ),
      )
    end
  end

  context "for an unsupported endpoint" do
    it "returns a 404" do
      user = create(:user)
      stub_sign_in(user)
      user.reload

      get :show, owner: "thoughtbot", repo: "hound", linter: "fortran"

      expect(response.status).to eq 404
    end
  end

  context "when user is not signed in" do
    it "redirects to root" do
      get :show, owner: "thoughtbot", repo: "hound", linter: "ruby"

      expect(response).to redirect_to(root_url)
    end
  end

  def stub_encoded_contents_request(options = {})
    repo_name = options.fetch(:repo_name)
    file = options.fetch(:file)
    sha = options.fetch(:sha)
    token = options.fetch(:token)
    content = Base64.encode64(options.fetch(:body))

    stub_request(
      :get,
      "https://api.github.com/repos/#{repo_name}/contents/#{file}?ref=#{sha}",
    ).with(
      headers: { "Authorization" => "token #{token}" },
    ).to_return(
      status: 200,
      body: { content: content }.to_json,
      headers: { "Content-Type" => "application/json; charset=utf-8" },
    )
  end
end
