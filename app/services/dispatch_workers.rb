class DispatchWorkers
  static_facade :run, :pull_request, :build

  def run
    pull_request_files.each do |file|
      linter = build_linter(file)

      if linter.enabled? && linter.file_included?(file)
        linter.run
      end
    end
  end

  private

  def pull_request_files
    pull_request.pull_request_files
  end

  def build_linter(file)
    linter = linter_class_name(file)
    linter.new(
      new_build_worker,
      file,
      repo_config,
      pull_request.repository_owner_name
    )
  end

  def new_build_worker
    build.build_workers.create
  end

  def linter_class_name(file)
    case file.filename
    when /.+\.rb\z/
      Language::RubyLocalLinter
    when /.+\.coffee(\.js)?\z/
      Language::CoffeeScriptLocalLinter
    when /.+\.js\z/
      Language::JavaScriptLocalLinter
    when /.+\.scss\z/
      scss_linter
    else
      Language::Unsupported
    end
  end

  def repo_config
    @repo_config ||= RepoConfig.new(pull_request.head_commit)
  end

  def scss_linter
    if ENV["IRON_WORKER_DISABLED"]
      Language::ScssLocalLinter
    else
      Language::Scss
    end
  end
end
