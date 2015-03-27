module ApiHelper
  def json_body
    JSON.parse(response.body)
  end

  def authorized_headers_for_build_worker
    header_token = ActionController::HttpAuthentication::Token.
      encode_credentials(ENV["BUILD_WORKERS_TOKEN"])
    @request.headers["HTTP_AUTHORIZATION"] = header_token
  end
end

RSpec.configure do |config|
  config.include ApiHelper, type: :controller
end
