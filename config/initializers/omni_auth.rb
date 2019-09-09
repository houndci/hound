OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :github,
    Hound::GITHUB_CLIENT_ID,
    Hound::GITHUB_CLIENT_SECRET,
    scope: "user:email",
  )
end
