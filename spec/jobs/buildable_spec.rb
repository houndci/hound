require 'fast_spec_helper'
require 'app/jobs/buildable'
require 'app/models/payload'
require 'app/services/build_runner'

describe Buildable do
  class TestJob
    extend Buildable
  end

  describe '.perform' do
    it 'runs build runner' do
      payload_data = double(:payload_data)
      payload = double(:payload)
      build_runner = double(:build_runner, run: nil)
      allow(Payload).to receive(:new).and_return(payload)
      allow(BuildRunner).to receive(:new).and_return(build_runner)

      TestJob.perform(payload_data)

      expect(Payload).to have_received(:new).with(payload_data)
      expect(BuildRunner).to have_received(:new).with(payload)
      expect(build_runner).to have_received(:run)
    end

    it 'retries when Resque::TermException is raised' do
      allow(Payload).to receive(:new).and_raise(Resque::TermException.new(1))
      allow(Resque).to receive(:enqueue)
      payload_data = double(:payload_data)

      TestJob.perform(payload_data)

      expect(Resque).to have_received(:enqueue).with(TestJob, payload_data)
    end
  end
end
