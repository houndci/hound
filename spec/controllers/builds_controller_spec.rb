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
      payload_data = File.read(
        'spec/support/fixtures/pull_request_opened_event.json'
      )
      payload = Payload.new(payload_data)
      allow(JobQueue).to receive(:push)

      post :create, payload: payload_data

      expect(JobQueue).to have_received(:push).
        with(SmallBuildJob, payload.build_data)
    end
  end

  context 'when number of changed files is at the threshold or above' do
    it 'enqueues large build job' do
      payload_data = File.read(
        'spec/support/fixtures/pull_request_event_with_many_files.json'
      )
      payload = Payload.new(payload_data)
      allow(JobQueue).to receive(:push)

      post :create, payload: payload_data

      expect(JobQueue).to have_received(:push).
        with(LargeBuildJob, payload.build_data)
    end
  end

  context "when payload is not for pull request" do
    it "does not schedule a job" do
      payload_data = File.read("spec/support/fixtures/push_event.json")
      allow(JobQueue).to receive(:push)

      post :create, payload: payload_data

      expect(JobQueue).not_to have_received(:push)
    end
  end
end
