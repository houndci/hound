class RedirectToConfiguration
  CONFIG_REGEX = %r{^/configuration.}

  def initialize(app)
    @app = app
  end

  def call(env)
    if new_location = old_to_new(env["PATH_INFO"])
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
    if CONFIG_REGEX.match(old)
      old.sub("configuration&", "configuration?&")
    end
  end
end
