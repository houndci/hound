RSpec.configure do |config|
  config.around(:each, type: :feature) do |example|
    run_background_jobs_immediately do
      example.call
    end
  end

  config.around(:each, type: :request) do |example|
    run_background_jobs_immediately do
      example.call
    end
  end

  config.around(:each, type: :job) do |example|
    run_background_jobs_immediately do
      example.call
    end
  end

  def run_background_jobs_immediately
    Sidekiq::Testing.inline! do
      yield
    end
  end
end
