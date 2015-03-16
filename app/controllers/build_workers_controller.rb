class BuildWorkersController < ApplicationController
  skip_before_action :authenticate

  def update
    build_worker = find_build_worker

    if not build_worker.completed?
      ReviewJob.perform_later(build_worker, file, violations)

      render json: {}, status: 201
    else
      error = "BuildWorker##{build_worker.id} has already been finished"

      render json: { error: error }, status: 412
    end
  end

  private

  def violations
    params[:violations]
  end

  def file
    params[:file]
  end

  def find_build_worker
    @find_build_worker ||= BuildWorker.find(params[:id])
  end
end
