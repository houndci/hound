OmniAuth.config.logger = Rails.logger
OmniAuth.config.allowed_request_methods = [:post, :get]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :github,
    Hound::GITHUB_CLIENT_ID,
    Hound::GITHUB_CLIENT_SECRET,
    scope: "user:email",
  )
end
