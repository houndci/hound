class BuildsController < ApplicationController
  skip_before_filter :authenticate

  def create
    pull_request = PullRequest.new(params[:payload])

    if pull_request.allowed?
      build_runner = BuildRunner.new(pull_request)
      build_runner.run

      render nothing: true
    else
      render text: 'Invalid GitHub action', status: 404
    end
  end
end
