class ReportInvalidConfigJob
  @queue = :high

  def self.perform(attributes)
    ReportInvalidConfig.run(
      pull_request_number: attributes.fetch("pull_request_number"),
      commit_sha: attributes.fetch("commit_sha"),
      filename: attributes.fetch("filename"),
    )
  end
end
