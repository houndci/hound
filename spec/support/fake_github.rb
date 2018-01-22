require "sinatra"

class FakeGithub < Sinatra::Base
  cattr_accessor :comments, :review_body
  self.comments = []

  put "/repos/:owner/:repo/collaborators/:username" do
    status 204
  end

  delete "/repos/:owner/:repo/collaborators/:username" do
    status 204
  end

  get "/repos/:owner/:repo/contents/:path" do
    content_type :json
    { content: "U3RyaW5nTGl0ZXJhbHM6CiAgRW5hYmxlZDogZmFsc2UK\n" }.to_json
  end

  post "/repos/:owner/:repo/hooks" do
    content_type :json
    status 201
    { id: 1 }.to_json
  end

  delete "/repos/:owner/:repo/hooks/:id" do
    status 204
  end

  get "/repos/:owner/:repo/pulls/:number/comments" do
    content_type :json
    [
      {
        body: "Line is too long.",
        commit_id: "TEST_GITHUB_COMMIT_ID",
        path: "path/to/test_github_file.rb",
        position: 5,
        pull_id: params[:number],
        repo: params[:repo],
      },
    ].to_json
  end

  post "/repos/:owner/:repo/pulls/:number/reviews" do
    request_payload = JSON.parse(request.body.read)
    self.review_body = request_payload["body"]

    request_payload["comments"].each do |comment|
      comments << build_comment(comment, params)
    end

    content_type :json
    status 201
  end

  get "/repos/:owner/:repo/pulls/:number/files" do
    content_type :json
    [
      {
        filename: "path/to/test_github_file.rb",
        patch: read_fixture("github_patch.diff"),
        status: "added",
      },
    ].to_json
  end

  post "/repos/:owner/:repo/statuses/:sha" do
    content_type :json
    status 201
  end

  get "/user" do
    headers "X-OAuth-Scopes" => "public_repo,user:email"
  end

  get "/user/repos" do
    content_type :json
    [
      {
        full_name: "TEST_GITHUB_LOGIN/TEST_GITHUB_REPO_NAME",
        id: 1,
        owner: { id: 1, login: "TEST_GITHUB_LOGIN" },
        permissions: { admin: true },
        private: false,
      },
    ].to_json
  end

  private

  def read_fixture(filename)
    File.read(File.join("spec", "support", "fixtures", filename))
  end

  def build_comment(comment, params)
    {
      body: comment["body"],
      path: comment["path"],
      position: comment["position"],
      pr_number: params[:number],
      repo: params[:repo],
    }
  end
end
