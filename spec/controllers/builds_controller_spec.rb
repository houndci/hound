require "rails_helper"

describe BuildsController, '#create' do
  it 'ignores confirmation pings' do
    zen_payload = File.read('spec/support/fixtures/zen_payload.json')

    post :create, params: { payload: zen_payload }

    expect(response.status).to eq 200
  end

  context 'when https is enabled' do
    context 'and http is used' do
      it 'does not redirect' do
        with_https_enabled do
          payload_data = File.read(
            'spec/support/fixtures/pull_request_opened_event.json'
          )
          post(:create, params: { payload: payload_data })

          expect(response).not_to be_redirect
        end
      end
    end
  end

  context 'when number of changed files is below the threshold' do
    it 'enqueues small build job' do
      allow(SmallBuildJob).to receive(:perform_async)
      payload_data = File.read(
        'spec/support/fixtures/pull_request_opened_event.json'
      )
      payload = Payload.new(payload_data)

      post :create, params: { payload: payload_data }

      expect(SmallBuildJob).to have_received(:perform_async).with(
        payload.build_data
      )
    end
  end

  context 'when number of changed files is at the threshold or above' do
    it 'enqueues large build job' do
      allow(LargeBuildJob).to receive(:perform_async)
      payload_data = File.read(
        'spec/support/fixtures/pull_request_event_with_many_files.json'
      )
      payload = Payload.new(payload_data)

      post :create, params: { payload: payload_data }

      expect(LargeBuildJob).to have_received(:perform_async).with(
        payload.build_data
      )
    end
  end

  context "when payload is not for pull request" do
    it "does not schedule a job" do
      payload_data = File.read("spec/support/fixtures/push_event.json")
      allow(LargeBuildJob).to receive(:perform_async)
      allow(SmallBuildJob).to receive(:perform_async)

      post :create, params: { payload: payload_data }

      expect(LargeBuildJob).not_to have_received(:perform_async)
      expect(SmallBuildJob).not_to have_received(:perform_async)
    end
  end

  context "when payload is not nested under a key" do
    it "enqueues a job" do
      payload_data = File.
        read("spec/support/fixtures/pull_request_opened_event.json")
      payload = Payload.new(payload_data)
      allow(SmallBuildJob).to receive(:perform_async)

      post :create, body: payload_data

      expect(SmallBuildJob).to have_received(:perform_async).
        with(payload.build_data)
    end
  end
end
