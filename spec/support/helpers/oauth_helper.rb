module OauthHelper
  def stub_oauth(options = {})
    OmniAuth.config.add_mock(
      :github,
      info: {
        nickname: options[:username],
        email: options[:email],
        name: options[:name],
      },
      credentials: {
        token: options[:token]
      }
    )
  end
end
