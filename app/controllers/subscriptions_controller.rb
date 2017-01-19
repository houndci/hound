class SubscriptionsController < ApplicationController
  class FailedToActivate < StandardError; end

  before_action :check_subscription_presence, only: :destroy
  before_action :update_email

  def create
    if Tier.new(current_user).full?
      head 402
    elsif activator.activate && create_subscription
      render json: repo, status: :created
    else
      activator.deactivate

      head 502
    end
  end

  def update
    if activator.activate && create_subscription
      render json: repo, status: :created
    else
      activator.deactivate
      head 502
    end
  end

  def destroy
    if activator.deactivate && delete_subscription
      analytics.track_repo_deactivated(repo)

      render json: repo, status: :created
    else
      head 502
    end
  end

  private

  def activator
    RepoActivator.new(repo: repo, github_token: github_token)
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
end
