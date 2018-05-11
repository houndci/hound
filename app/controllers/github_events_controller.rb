class GitHubEventsController < ApplicationController
  skip_before_action :authenticate, only: :create
  skip_before_action :verify_authenticity_token, only: :create

  def create
    case request.headers["X-GitHub-Event"]
    when "marketplace_purchase"
      request_body = request.raw_post
      signature = request.headers["X-Hub-Signature"]

      if verified_github_request?(request_body, signature)
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
          raise "Unknown GitHub Marketplace action (#{event["action"]})"
        end
      else
        raise "Could not verify GitHub request (#{request.headers["X-GitHub-Delivery"]})"
      end
    else
      raise "Unknown GitHub event (#{request.headers["X-GitHub-Event"]})"
    end

    head :ok
  end

  private

  def verified_github_request?(request_body, signature)
    sha = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new("sha1"),
      ENV.fetch("GITHUB_WEBHOOK_SECRET"),
      request_body,
    )

    Rack::Utils.secure_compare("sha1=#{sha}", signature)
  end

  def upsert_owner(event)
    Owner.upsert(
      github_id: event["marketplace_purchase"]["account"]["id"],
      name: event["marketplace_purchase"]["account"]["login"],
      organization: event["marketplace_purchase"]["account"]["type"] == GitHubApi::ORGANIZATION_TYPE,
    )
  end
end
