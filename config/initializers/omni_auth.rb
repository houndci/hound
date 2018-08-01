OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  setup = ->(env) do
    options = GitHubAuthOptions.new(env)
    env["omniauth.strategy"].options.merge!(options.to_hash)
  end

  provider(
    :github,
    Hound::GITHUB_CLIENT_ID,
    Hound::GITHUB_CLIENT_SECRET,
    setup: setup,
    provider_ignores_state: true,
  )
end
