class StyleCheck
  def initialize(pull_request, build_worker)
    @pull_request = pull_request
    @build_worker = build_worker
    @workers = {}
  end

  def run
    files_to_check.each do |file|
      worker(file).run
    end
  end

  private

  attr_reader :pull_request, :build_worker, :workers

  def files_to_check
    pull_request_files.select do |file|
      file_worker = worker(file)
      file_worker.enabled? && file_worker.file_included?(file)
    end
  end

  def pull_request_files
    pull_request.pull_request_files(&:removed?)
  end

  def worker(file)
    worker_class_name = worker_class_name(file)
    workers[worker_class_name] ||= worker_class_name.new(
      build_worker,
      file,
      repo_config,
      pull_request
    )
  end

  def worker_class_name(file)
    case file.filename
    when /.+\.rb\z/
      LanguageWorker::Ruby
    when /.+\.coffee(\.js)?\z/
      LanguageWorker::CoffeeScript
    when /.+\.js\z/
      LanguageWorker::JavaScript
    when /.+\.scss\z/
      LanguageWorker::Scss
    else
      LanguageWorker::Unsupported
    end
  end

  def repo_config
    @repo_config ||= RepoConfig.new(pull_request.head_commit)
  end
end
