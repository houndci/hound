module OauthHelper
  def stub_oauth(username = 'jimtom')
    OmniAuth.config.add_mock(:github, info: { nickname: username })
  end
end
