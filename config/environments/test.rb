ENV['HOST'] = 'test.host'
ENV['RAILS_SECRET_TOKEN'] = '2a83e3ca30389f875107cbdade2a838fd3859cdec42f566fed69f555c94379dcb66bf38b414e2a8718e16547ea23163acbc9e6d7323aba9bc67dd2a49e0197fe'

Houndapp::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.eager_load = false

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { :host => ENV['HOST'] }

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
end
