OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  setup = lambda do |env|
    options = GithubAuthOptions.new(env)
    env["omniauth.strategy"].options.merge!(options.to_hash)
  end

  provider(
    :github,
    ENV['GITHUB_CLIENT_ID'],
    ENV['GITHUB_CLIENT_SECRET'],
    setup: setup
  )
end
