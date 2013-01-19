module OauthHelper
  def stub_oauth(username = 'jimtom', token = 'authtoken')
    OmniAuth.config.add_mock(
      :github,
      info: {
        nickname: username
      },
      credentials: {
        token: token
      }
    )
  end
end
