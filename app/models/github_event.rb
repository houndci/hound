# frozen_string_literal: true

class GitHubEvent
  MARKETPLACE_PURCHASE = "marketplace_purchase"
  PULL_REQUEST = "pull_request"
  CANCELLATION = "cancelled"
  INSTALLATION = "installation"
  INSTALLATION_REPOSITORIES = "installation_repositories"

  def initialize(type:, body:)
    @body = body
    @type = type
  end

  def process
    Rails.logger.info("Received GitHub event: #{type} -- #{action}")
    case type
    when MARKETPLACE_PURCHASE
      update_purchase
    when PULL_REQUEST
      run_build
    when CANCELLATION
      owner = Owner.find_by!(
        github_id: body["marketplace_purchase"]["account"]["id"],
      )
      owner.active_private_repos.each(&:deactivate)
    when INSTALLATION
      update_installation
    when INSTALLATION_REPOSITORIES
      update_installation
    else
      Rails.logger.info("Unhandled GitHub event: #{type} -- #{action}")
    end
  end

  private

  attr_reader :body, :type

  def run_build
    case action
    when "opened", "reopened", "synchronize"
      build_job_class.perform_later(payload.build_data)
    end
  end

  def update_purchase
    owner = upsert_owner

    case action
    when "purchased", "changed"
      owner.update!(
        marketplace_plan_id: body["marketplace_purchase"]["plan"]["id"],
      )
    when "cancelled"
      owner.repos.update_all(active: false)
      owner.update!(marketplace_plan_id: nil)
    else
      raise "Unknown GitHub Marketplace action (#{action})"
    end
  end

  def update_installation
    case action
    when "deleted"
      repos = Repo.where(installation_id: body["installation"]["id"])
      repos.update_all(active: false, installation_id: nil)
    when "removed"
      repos = Repo.where(
        installation_id: body["installation"]["id"],
        github_id: body["repositories_removed"].map { |repo| repo["id"] }
      )
      repos.update_all(active: false, installation_id: nil)
    when "added"
      repos = Repo.where(
        github_id: body["repositories_added"].map { |repo| repo["id"] }
      )
      repos.update_all(installation_id: body["installation"]["id"])
    end
  end

  def upsert_owner
    Owner.upsert(
      github_id: body["marketplace_purchase"]["account"]["id"],
      name: body["marketplace_purchase"]["account"]["login"],
      organization: organization_event?,
    )
  end

  def organization_event?
    account_type = body["marketplace_purchase"]["account"]["type"]
    account_type == GitHubApi::ORGANIZATION_TYPE
  end

  def build_job_class
    if payload.changed_files < Hound::CHANGED_FILES_THRESHOLD
      SmallBuildJob
    else
      LargeBuildJob
    end
  end

  def payload
    @_payload ||= Payload.new(body)
  end

  def action
    body.fetch("action")
  end
end
