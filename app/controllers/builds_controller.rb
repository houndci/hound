class BuildsController < ApplicationController
  before_action :ignore_confirmation_pings, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :authenticate, only: [:create]

  def create
    JobQueue.push(build_job_class, payload.data)
    head :ok
  end

  private

  def force_https?
    false
  end

  def ignore_confirmation_pings
    if payload.ping?
      head :ok
    end
  end

  def build_job_class
    if payload.changed_files < ENV['CHANGED_FILES_THRESHOLD'].to_i
      SmallBuildJob
    else
      LargeBuildJob
    end
  end

  def payload
    @payload ||= Payload.new(params[:payload] || request.raw_post)
  end
end
