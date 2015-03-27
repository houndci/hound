class DispatchWorkers
  static_facade :run, :pull_request, :build

  def run
    pull_request_files.each do |file|
      file_worker = worker(file)

      if file_worker.enabled? && file_worker.file_included?(file)
        file_worker.run
      end
    end
  end

  private

  def pull_request_files
    pull_request.pull_request_files
  end

  def worker(file)
    worker_class_name = worker_class_name(file)
    worker_class_name.new(
      new_build_worker,
      file,
      repo_config,
      pull_request.repository_owner_name
    )
  end

  def new_build_worker
    build.build_workers.create
  end

  def worker_class_name(file)
    case file.filename
    when /.+\.rb\z/
      Language::RubyLegacyWorker
    when /.+\.coffee(\.js)?\z/
      Language::CoffeeScriptLegacyWorker
    when /.+\.js\z/
      Language::JavaScriptLegacyWorker
    when /.+\.scss\z/
      scss_worker
    else
      Language::Unsupported
    end
  end

  def repo_config
    @repo_config ||= RepoConfig.new(pull_request.head_commit)
  end

  def scss_worker
    if ENV["IRON_WORKER_ENABLED"]
      Language::Scss
    else
      Language::ScssLegacyWorker
    end
  end
end
