require 'spec_helper'

describe BuildsController, '#create' do
  it 'ignores confirmation pings' do
    zen_payload = File.read('spec/support/fixtures/zen_payload.json')

    post :create, payload: zen_payload

    expect(response.status).to eq 200
  end

  context 'when https is enabled' do
    context 'and http is used' do
      it 'does not redirect' do
        with_https_enabled do
          payload_data = File.read(
            'spec/support/fixtures/pull_request_opened_event.json'
          )
          post(:create, payload: payload_data)

          expect(response).not_to be_redirect
        end
      end
    end
  end

  context 'when number of changed files is below the threshold' do
    it 'enqueues job with high priority' do
      Delayed::Job.stub(:enqueue)
      payload_data = File.read(
        'spec/support/fixtures/pull_request_opened_event.json'
      )
      post(:create, payload: payload_data)

      expect(Delayed::Job).to have_received(:enqueue).
        with(anything, priority: BuildsController::HIGH_PRIORITY)
    end
  end

  context 'when number of changed files is at the threshold or above' do
    it 'enqueues job with low priority' do
      Delayed::Job.stub(:enqueue)
      payload_data = File.read(
        'spec/support/fixtures/pull_request_event_with_many_files.json'
      )
      post(:create, payload: payload_data)

      expect(Delayed::Job).to have_received(:enqueue).
        with(anything, priority: BuildsController::LOW_PRIORITY)
    end
  end
end
