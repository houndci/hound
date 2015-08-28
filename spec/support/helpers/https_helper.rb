module HttpsHelper
  def with_https_enabled
    stub_const("Hound::HTTPS_ENABLED", "yes")
    yield
    stub_const("Hound::HTTPS_ENABLED", "no")
  end
end
