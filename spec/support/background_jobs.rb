module BackgroundJobs
  def run_background_jobs_immediately
    delay_jobs = Resque.inline
    Resque.inline = true
    yield
  ensure
    Resque.inline = delay_jobs
  end
end

RSpec.configure do |config|
  config.around(:each, type: :feature) do |example|
    run_background_jobs_immediately do
      example.run
    end
  end

  config.around(:each, :run_background_jobs_immediately) do |example|
    run_background_jobs_immediately do
      example.run
    end
  end

  config.include BackgroundJobs
end
