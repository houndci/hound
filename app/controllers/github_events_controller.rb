class GitHubEventsController < ApplicationController
  skip_before_action :authenticate, only: :create
  skip_before_action :verify_authenticity_token, only: :create

  before_action :verify_github_request

  def create
    GitHubEvent.new(type: event_type, body: JSON.parse(request_body)).process

    head :ok
  end

  private

  def verify_github_request
    sha = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new("sha1"),
      ENV.fetch("GITHUB_WEBHOOK_SECRET"),
      request_body,
    )

    unless Rack::Utils.secure_compare("sha1=#{sha}", signature)
      raise "Could not verify GitHub request (#{event_id})"
    end
  end

  def request_body
    request.raw_post
  end

  def signature
    request.headers["X-Hub-Signature"]
  end

  def event_type
    request.headers["X-GitHub-Event"]
  end

  def event_id
    request.headers["X-GitHub-Delivery"]
  end
end
