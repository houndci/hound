require 'fast_spec_helper'
require 'app/models/payload'
require 'json'

describe Payload do
  describe '#opened?' do
    context 'when action is opened' do
      it 'returns true' do
        payload = Payload.new(
          File.read('spec/support/fixtures/pull_request_opened_event.json')
        )

        expect(payload).to be_opened
      end
    end
  end

  describe '#synchronize?' do
    context 'when action is synchronize' do
      it 'returns true' do
        payload = Payload.new(
          File.read('spec/support/fixtures/pull_request_synchronize_event.json')
        )

        expect(payload).to be_synchronize
      end
    end
  end
end
