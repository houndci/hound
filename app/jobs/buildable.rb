require 'resque'

module Buildable
  def perform(payload_data)
    payload = Payload.new(payload_data)
    Owner.upsert(
      github_id: payload.repository_owner_id,
      name: payload.repository_owner_name,
      organization: payload.repository_owner_is_organization?
    )
    build_runner = BuildRunner.new(payload)
    build_runner.run
  rescue Resque::TermException
    Resque.enqueue(self, payload_data)
  end
end
