# frozen_string_literal: true

module OauthHelper
  def stub_oauth(options = {})
    OmniAuth.config.add_mock(
      :github,
      info: {
        nickname: options[:username],
        email: options[:email]
      },
      credentials: {
        token: options[:token]
      }
    )
  end
end
