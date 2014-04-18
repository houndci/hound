require 'fast_spec_helper'
require 'app/models/payload'

describe Payload do
  describe '#changed_files' do
    it 'returns number of changed files' do
      payload_json = File.read(
        'spec/support/fixtures/pull_request_opened_event.json'
      )
      payload = Payload.new(payload_json)

      expect(payload.changed_files).to eq 1
    end
  end

  describe '#data' do
    it 'returns data' do
      data = {one: 1}
      payload = Payload.new(data)

      expect(payload.data).to eq data
    end
  end
end
