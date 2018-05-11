class GitHubEventsController < ApplicationController
  skip_before_action :authenticate, only: :create
  skip_before_action :verify_authenticity_token, only: :create

  before_action :verify_github_request

  def create
    case event_type
    when "marketplace_purchase"
      event = JSON.parse(request_body)
      action = event.fetch("action")
      owner = upsert_owner(event)

      case action
      when "purchased", "changed"
        owner.update!(
          marketplace_plan_id: event["marketplace_purchase"]["plan"]["id"],
        )
      when "cancelled"
        owner.update!(
          marketplace_plan_id: nil,
        )
      else
        raise "Unknown GitHub Marketplace action (#{action})"
      end
    else
      raise "Unknown GitHub event (#{event_type})"
    end

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

  def upsert_owner(event)
    Owner.upsert(
      github_id: event["marketplace_purchase"]["account"]["id"],
      name: event["marketplace_purchase"]["account"]["login"],
      organization: event["marketplace_purchase"]["account"]["type"] == GitHubApi::ORGANIZATION_TYPE,
    )
  end
end
