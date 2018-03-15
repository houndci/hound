# frozen_string_literal: true

class DeletedSubscriptionsController < ApplicationController
  skip_before_action :authenticate, only: :create

  def create
    DeleteSubscriptions.call(params)

    head :ok
  end
end
