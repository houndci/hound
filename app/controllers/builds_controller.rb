class BuildsController < ApplicationController
  before_action :ignore_confirmation_pings, only: [:create]
  skip_before_filter :verify_authenticity_token, only: [:create]
  skip_before_filter :authenticate, only: [:create]

  HIGH_PRIORITY = 1
  LOW_PRIORITY = 2

  def create
    Delayed::Job.enqueue(build_job, priority: priority)
    head :ok
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

  def build_job
    BuildJob.new(build_runner)
  end

  def build_runner
    BuildRunner.new(payload)
  end

  def payload
    Payload.new(event_data)
  end

  def event_data
    JSON.parse(params[:payload] || request.raw_post)
  end

  def ignore_confirmation_pings
    if event_data.key?('zen')
      head :ok
    end
  end

  def priority
    if payload.changed_files < ENV['CHANGED_FILES_THRESHOLD'].to_i
      HIGH_PRIORITY
    else
      LOW_PRIORITY
    end
  end
end
