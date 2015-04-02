class BuildWorkersController < ApplicationController
  before_action :authenticate_with_token
  skip_before_action(
    :authenticate,
    :capture_campaign_params,
    :verify_authenticity_token,
  )

  def update
    if build_worker.running?
      ReviewJob.perform_later(build_worker, file, violations)

      render json: {}, status: 201
    end
  end

  private

  def violations
    params[:violations]
  end

  def file
    params[:file]
  end

  def build_worker
    @build_worker ||= BuildWorker.find(params[:id])
  end

  def authenticate_with_token
    authenticate_or_request_with_http_token do |token, _|
      token.size == build_workers_token.size &&
        ActiveSupport::SecurityUtils.secure_compare(token, build_workers_token)
    end
  end

  def build_workers_token
    ENV.fetch("BUILD_WORKERS_TOKEN")
  end
end
