class PagesController < ApplicationController
  include HighVoltage::StaticPage

  skip_before_action :authenticate

  def configuration
    @versions = LinterVersion.all
  end
end
