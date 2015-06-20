Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :github,
    ENV["GITHUB_CLIENT_ID"],
    ENV["GITHUB_CLIENT_SECRET"],
    scope: 'user:email,repo'
  )
  provider(
    :bitbucket,
    ENV["BITBUCKET_CLIENT_ID"],
    ENV["BITBUCKET_CLIENT_SECRET"]
  ) if ENV.fetch("BITBUCKET_ENABLED", false)
end
