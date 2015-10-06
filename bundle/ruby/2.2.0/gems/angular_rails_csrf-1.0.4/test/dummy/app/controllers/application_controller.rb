class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def index;  head :ok; end
  def create; head :ok; end
end
