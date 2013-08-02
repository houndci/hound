class BuildsController < ApplicationController
  skip_before_filter :authenticate

  def show
    @build = Build.find(params[:id])
  end

  def create
    pull_request = PullRequest.new(params[:payload])
    build_runner = BuildRunner.new(pull_request)

    if build_runner.valid?
      build_runner.run

      render nothing: true
    else
      render text: 'Invalid GitHub action', status: 404
    end
  end
end
