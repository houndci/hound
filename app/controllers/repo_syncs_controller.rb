# frozen_string_literal: true

class RepoSyncsController < ApplicationController
  def create
    unless current_user.refreshing_repos?
      current_user.update_attribute(:refreshing_repos, true)

      RepoSynchronizationJob.perform_later(current_user)
    end

    head 201
  end
end
