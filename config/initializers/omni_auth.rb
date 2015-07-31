Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :github,
    ENV['GITHUB_CLIENT_ID'],
    ENV['GITHUB_CLIENT_SECRET'],
    setup: ->(env) {
      options = GithubAuthOptions.new(env)
      env["omniauth.strategy"].options.merge!(options.to_hash)
    }
  )
end
