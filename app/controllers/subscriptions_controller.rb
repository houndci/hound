class SubscriptionsController < ApplicationController
  class FailedToActivate < StandardError; end

  before_action :update_email_address

  respond_to :json

  def create
    if activator.activate && create_subscription
      analytics.track_subscribed(repo)

      render json: repo, status: :created
    else
      activator.deactivate

      head 502
    end
  end

  def destroy
    if activator.deactivate && delete_subscription
      analytics.track_unsubscribed(repo)

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
    @repo ||= current_user.repos.find(params.fetch(:repo_id))
  end

  def github_token
    session.fetch(:github_token)
  end

  def create_subscription
    RepoSubscriber.subscribe(repo, current_user, params[:card_token])
  end

  def delete_subscription
    RepoSubscriber.unsubscribe(repo, repo.subscription.user)
  end

  def update_email_address
    if current_user.email_address.blank?
      current_user.update(email_address: params[:email_address])
    end
  end
end
