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
        allow(JobQueue).to receive(:push)

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
    it 'enqueues small build job' do
      allow(JobQueue).to receive(:push)
      payload_data = File.read(
        'spec/support/fixtures/pull_request_opened_event.json'
      )

      post :create, payload: payload_data

      expect(JobQueue).to have_received(:push).with(
        SmallBuildJob,
        JSON.parse(payload_data)
      )
    end
  end

  context 'when number of changed files is at the threshold or above' do
    it 'enqueues large build job' do
      allow(JobQueue).to receive(:push)
      payload_data = File.read(
        'spec/support/fixtures/pull_request_event_with_many_files.json'
      )

      post :create, payload: payload_data

      expect(JobQueue).to have_received(:push).with(
        LargeBuildJob,
        JSON.parse(payload_data)
      )
    end
  end
end
