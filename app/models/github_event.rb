# frozen_string_literal: true

class GitHubEvent
  MARKETPLACE_PURCHASE = "marketplace_purchase"
  PULL_REQUEST = "pull_request"
  CANCELLATION = "cancelled"
  INSTALLATION = "installation"
  INSTALLATION_REPOSITORIES = "installation_repositories"
  CHECK_SUITE = "check_suite"
  CHECK_SUITE = "check_run"

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
    when INSTALLATION, INSTALLATION_REPOSITORIES
      update_installation
    when CHECK_SUITE
      if body["action"] == "requested"
        # create a check run
        repo = Repo.find_by!(github_id: body["repository"]["id"])
        token = GitHubAuth.new(repo).token
        api = GitHubApi.new(token)
        api.send(:client).create_check_run(
          body["repository"]["full_name"],
          "Hound",
          body["check_suite"]["head_sha"]
        )
      end
    when CHECK_RUN
      if body["action"] == "created"
        # update check run with build info
        # repo = Repo.find_by!(github_id: body["repository"]["id"])
        # token = GitHubAuth.new(repo).token
        # api = GitHubApi.new(token)
        # api.send(:client).update_check_run(
        #   body["repository"]["full_name"],
        #   body["check_run"]["id"],
        #   name: "Hound",
        # )


        # api.send(:client).update_check_run("salbertson/sidekiq_toolbelt", 112179565, name: "Hound", status: "completed", conclusion: "neutral", completed_at: Time.now.utc.iso8601, output: {title: "Hound", summary: "Hound Summary\n-There were a few issues", text: "RuboCop version 0.123", annotations: [{path: "README.md", start_line: 1, end_line: 1, annotation_level: "notice", message: "Don't do that"}]}, actions: [{label: "Fix this", description: "Do some magic", identifier: "fix_rubocop_notices"}])
      end
    else
      Rails.logger.info("Unhandled GitHub event: #{type} -- #{action}")
    end
  end

  private

  attr_reader :body, :type

  def run_build
    case action
    when "opened", "reopened", "synchronize"
      build_job_class.perform_async(payload.build_data)
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

      users = User.where(
        "? = ANY(installation_ids)",
        body["installation"]["id"],
      )
      users.find_each do |user|
        user.installation_ids.delete(body["installation"]["id"])
        user.save!
      end
    when "removed"
      repos = Repo.where(
        installation_id: body["installation"]["id"],
        github_id: body["repositories_removed"].map { |repo| repo["id"] },
      )
      repos.update_all(active: false, installation_id: nil)
    when "added"
      repos = Repo.where(
        github_id: body["repositories_added"].map { |repo| repo["id"] },
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
