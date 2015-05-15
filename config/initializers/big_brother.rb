unless Rails.env.test?
  stack = Faraday::RackBuilder.new do |builder|
    builder.use BigBrother
    builder.use Octokit::Response::RaiseError
    builder.adapter Faraday.default_adapter
  end

  Octokit.middleware = stack
end
