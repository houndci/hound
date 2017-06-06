class ReportInvalidConfigJob
  @queue = :high

  # The following parameters are required for this job to run.
  # - pull_request_number
  # - commit_sha
  # - linter_name
  #
  # The following parameters are optional:
  # - message
  # - details_url
  def self.perform(attributes)
    ReportInvalidConfig.call(
      pull_request_number: attributes.fetch("pull_request_number"),
      commit_sha: attributes.fetch("commit_sha"),
      linter_name: attributes.fetch("linter_name"),
      message: attributes["message"],
      details_url: attributes["details_url"],
    )
  end
end
