stack = Faraday::Builder.new do |builder|
  builder.use Faraday::HttpCache, store: Rails.cache, shared_cache: false
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
Octokit.middleware = stack
