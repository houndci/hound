stack = Faraday::RackBuilder.new do |builder|
  builder.use(
    Faraday::HttpCache,
    store: Rails.cache,
    shared_cache: false,
    serializer: Marshal
  )
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
Octokit.middleware = stack
