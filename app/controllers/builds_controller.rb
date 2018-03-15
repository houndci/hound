# frozen_string_literal: true

class BuildsController < ApplicationController
  before_action :ignore_confirmation_pings, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :authenticate, only: [:create]

  def index
    render locals: { builds: recent_builds_by_repo }
  end

  def create
    if payload.pull_request?
      build_job_class.perform_later(payload.build_data)
    end
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
    if payload.changed_files < Hound::CHANGED_FILES_THRESHOLD
      SmallBuildJob
    else
      LargeBuildJob
    end
  end

  def payload
    @payload ||= Payload.new(params[:payload] || request.raw_post)
  end

  def recent_builds_by_repo
    RecentBuildsByRepoQuery.call(user: current_user)
  end
end
