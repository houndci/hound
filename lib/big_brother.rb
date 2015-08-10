require "faraday"

class BigBrother < Faraday::Response::Middleware
  def on_complete(env)
    Rails.logger.info "#{tag(env)} #{env.url}"
  end

  private

  def tag(env)
    if hound?(env)
      "[BIG_BROTHER] [HOUND]"
    else
      "[BIG_BROTHER] [USER]"
    end
  end

  def hound?(env)
    env.request_headers["Authorization"].include?(Hound::GITHUB_TOKEN)
  end
end
