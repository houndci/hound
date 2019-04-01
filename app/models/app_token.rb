class AppToken
  def initialize
    private_pem = Hound::GITHUB_APP_PEM.gsub('\n', "\n")
    @private_key = OpenSSL::PKey::RSA.new(private_pem)
  end

  def generate
    issue_time = Time.now.to_i
    expiration_time = issue_time + (10 * 60 - 10)
    payload = {
      iat: issue_time,
      exp: expiration_time,
      iss: Hound::GITHUB_APP_ID,
    }

    JWT.encode(payload, @private_key, "RS256")
  end
end
