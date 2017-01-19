require "sinatra"

class FakeGithub < Sinatra::Base
  Comment = Struct.new(:body, :commit_id, :path, :position, :pull_id, :repo)

  cattr_accessor :comments
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

  post "/repos/:owner/:repo/pulls/:number/comments" do
    request.body.rewind
    request_payload = JSON.parse(request.body.read)

    comments << Comment.new(
      request_payload["body"],
      request_payload["commit_id"],
      request_payload["path"],
      request_payload["position"],
      params[:number],
      params[:repo],
    )

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
end
