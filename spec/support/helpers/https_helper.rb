module HttpsHelper
  def with_https_enabled
    Rails.application.routes.default_url_options[:protocol] = "https"
    yield
    Rails.application.routes.default_url_options[:protocol] = "http"
  end
end
