class BuildsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create]
  skip_before_filter :authenticate

  def show
    @build = Build.find(params[:id])
  end

  def create
    if pull_request.valid?
      Delayed::Job.enqueue(build_job)

      render nothing: true
    else
      render text: 'Invalid GitHub action', status: 404
    end
  end

  private

  def build_job
    BuildJob.new(build_runner)
  end

  def build_runner
    @build_runner ||= BuildRunner.new(pull_request)
  end

  def pull_request
    payload = JSON.parse(params[:payload])
    PullRequest.new(payload)
  end
end
