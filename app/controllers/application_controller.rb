class ApplicationController < ActionController::Base
  include Clearance::Authentication
  protect_from_forgery
end
