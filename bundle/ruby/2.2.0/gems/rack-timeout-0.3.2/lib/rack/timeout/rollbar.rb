require_relative "core"

# Groups timeout exceptions in rollbar by exception class, http method, and url.
#
# Usage: after requiring rollbar (say, in your rollbar initializer file), call:
#
#   require "rack/timeout/rollbar"
#
# This is somewhat experimental and very lightly tested.
#
# Ruby 2.0 is required as we use `Module.prepend`.

module Rack::Timeout::Rollbar
  def build_payload(level, message, exception, extra)
    payload = super(level, message, exception, extra)

    return payload unless exception.is_a?(::Rack::Timeout::ExceptionWithEnv) \
                       && payload.respond_to?(:[])                           \
                       && payload.respond_to?(:[]=)

    data = payload["data"]
    return payload unless data.respond_to?(:[]=)

    request = ::Rack::Request.new(exception.env)
    payload = payload.dup
    data    = data.dup
    payload["data"] = data

    data["fingerprint"] = [
      exception.class.name,
      request.request_method,
      request.fullpath
      ].join(" ")

    return payload
  end
end

::Rollbar::Notifier.prepend ::Rack::Timeout::Rollbar
