class RedirectToConfiguration
  CONFIG_REGEX = %r{^/configuration.}

  def initialize(app)
    @app = app
  end

  def call(env)
    new_location = old_to_new(env["PATH_INFO"])

    if new_location
      [
        301,
        { "Location" => new_location, "Content-Type" => "text/html" },
        ["Moved permanently to #{new_location}"]
      ]
    else
      @app.call(env)
    end
  end

  private

  def old_to_new(old)
    old.sub("configuration&", "configuration?&") if CONFIG_REGEX.match(old)
  end
end
