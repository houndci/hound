class BuildsController < ApplicationController
  before_action :ignore_confirmation_pings, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:create]
  skip_before_filter :authenticate

  def create
    if build_runner.valid?
      Delayed::Job.enqueue(build_job)

      render nothing: true
    else
      render text: 'Invalid GitHub action', status: 404
    end
  end

  private

  def force_https?
    false
  end

  def build_job
    BuildJob.new(build_runner)
  end

  def build_runner
    @build_runner ||= BuildRunner.new(payload)
  end

  def payload
    Payload.new(event_data)
  end

  def ignore_confirmation_pings
    if event_data.key?('zen')
      head :ok
    end
  end

  def event_data
    JSON.parse(params[:payload] || request.raw_post)
  end
end
