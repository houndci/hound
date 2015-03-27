class BuildWorkerConfig
  def self.token
    @@token
  end

  def self.token=(env_token)
    @@token = env_token
  end

  def self.url
    @@url
  end

  def self.url=(env_url)
    @@url = env_url
  end
end

BuildWorkerConfig.token = ENV.fetch("BUILD_WORKERS_TOKEN")
BuildWorkerConfig.url = ENV.fetch("BUILD_WORKERS_URL")
