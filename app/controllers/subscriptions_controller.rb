class SubscriptionsController < ApplicationController
  class FailedToActivate < StandardError; end

  before_action :check_subscription_presence, only: :destroy
  before_action :update_email

  def create
    plan_selector = PlanSelector.new(repo.owner)

    if plan_selector.paywall?
      render json: {}, status: :payment_required
    elsif plan_selector.upgrade?
      render json: {}, status: :payment_required
    else
      repo.activate

      render json: repo, status: :created
    end
  end

  def update
    activate_and_create_subscription
  end

  def destroy
    if deactivate_repo
      if delete_subscription
        analytics.track_repo_deactivated(repo)

        render json: repo, status: :created
      else
        render_error("There was an issue deleting the subscription")
      end
    else
      render_error("There was an issue deactivating the repo")
    end
  end

  private

  def deactivate_repo
    DeactivateRepo.call(repo: repo, github_token: github_token)
  end

  def repo
    @repo ||= current_user.repos.find_by(id: params.fetch(:repo_id)) ||
      current_user.subscribed_repos.find(params.fetch(:repo_id))
  end

  def github_token
    current_user.token
  end

  def create_subscription
    RepoSubscriber.subscribe(repo, current_user, params[:card_token])
  end

  def delete_subscription
    RepoSubscriber.unsubscribe(repo, repo.subscription.user)
  end

  def check_subscription_presence
    if repo.subscription.blank?
      render(
        json: { errors: ["No subscription exists for this repo"] },
        status: :conflict
      )
    end
  end

  def update_email
    if current_user.email.blank?
      current_user.update(email: params[:email])
    end
  end

  def activate_and_create_subscription
    repo.activate

    if create_subscription
      render json: repo, status: :created
    else
      deactivate_repo

      render_error("There was an issue creating the subscription")
    end
  end

  def render_error(error)
    Raven.capture_message(
      error,
      extra: {
        repo: repo.name,
        repo_id: repo.id,
        user_email: current_user.email,
        username: current_user.username,
      },
    )

    render json: { errors: [error] }, status: :bad_gateway
  end
end
