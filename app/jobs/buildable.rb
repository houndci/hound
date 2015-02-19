require 'resque'

module Buildable
  def perform(payload_data)
    payload = Payload.new(payload_data)
    build_runner = BuildRunner.new(payload)
    build_runner.run
  rescue Resque::TermException
    Resque.enqueue(self, payload_data)
  rescue => exception
    Raven.capture_exception(exception, payload: { data: payload_data })
  end
end
