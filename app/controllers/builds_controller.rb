class BuildsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]
  skip_before_filter :authenticate

  def show
    @build = Build.find(params[:id])
  end

  def create
    pull_request = PullRequest.new(pull_request_attributes)
    Delayed::Job.enqueue(BuildJob.new(pull_request))

    head 201
  end

  private

  def pull_request_attributes
    JSON.parse(params[:payload])
  end
end
