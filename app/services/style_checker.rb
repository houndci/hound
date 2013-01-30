class StyleChecker
  def check(pull_request, github_token)
    api = GithubApi.new(github_token)
    api.create_pending_status(pull_request, 'Hound is working...')
  end
end
