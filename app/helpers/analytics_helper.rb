module AnalyticsHelper
  def analytics?
    ENV['ANALYTICS']
  end
end
