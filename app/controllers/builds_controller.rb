class BuildsController < ApplicationController
  skip_before_filter :authenticate

  def create
    pull_request = PullRequest.new(params[:payload])
    build = Build.new(pull_request)

    if build.valid?
      build.run

      render nothing: true
    else
      render text: 'Invalid GitHub action', status: 404
    end
  end
end
