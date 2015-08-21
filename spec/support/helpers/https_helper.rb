module HttpsHelper
  def with_https_enabled
    ENV['ENABLE_HTTPS'] = 'yes'
    yield
    ENV['ENABLE_HTTPS'] = 'no'
  end
end
