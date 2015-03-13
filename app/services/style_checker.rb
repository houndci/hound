class StyleChecker
  def initialize(pull_request, build)
    @pull_request = pull_request
    @build = build
  end

  def run
    pull_request_files.select do |file|
      file_worker = worker(file)

      if file_worker.enabled? && file_worker.file_included?(file)
        file_worker.run
      end
    end
  end

  private

  attr_reader :pull_request, :build

  def pull_request_files
    pull_request.pull_request_files(&:removed?)
  end

  def worker(file)
    worker_class_name = worker_class_name(file)
    worker_class_name.new(
      new_build_worker,
      file,
      repo_config,
      pull_request
    )
  end

  def new_build_worker
    build.build_workers.create
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
