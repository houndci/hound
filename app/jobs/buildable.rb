module Buildable
  def perform(payload_data)
    payload = Payload.new(payload_data)
    BuildRunner.run(payload)
  rescue Resque::TermException
    retry_job
  rescue => exception
    Raven.capture_exception(exception, payload: { data: payload_data })
  end
end
