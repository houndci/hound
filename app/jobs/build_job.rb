class BuildJob
  def initialize(pull_request)
    @pull_request = pull_request
  end

  def perform
    if pull_request.valid?
      build_runner = BuildRunner.new(pull_request)
      build_runner.run
    end
  end

  private

  attr_reader :pull_request
end
