## This controller uses includes

class BarController < ApplicationController
  def index
    Rails.logger.info "Logging with Rails.logger" # Printed to STDOUT
    logger.info "Logging with logger"             # Not printed to STDOUT

    Rails.logger.silence {
      Rails.logger.info "This should not be logged!"
    }
  end

  def update
  end
end
