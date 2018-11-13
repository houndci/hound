Split::Dashboard.use(Rack::Auth::Basic) do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(
    ::Digest::SHA256.hexdigest(username),
    ::Digest::SHA256.hexdigest(ENV.fetch("SPLIT_USERNAME"))
  ) & ActiveSupport::SecurityUtils.secure_compare(
    ::Digest::SHA256.hexdigest(password),
    ::Digest::SHA256.hexdigest(ENV.fetch("SPLIT_PASSWORD"))
  )
end
