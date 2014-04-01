require 'spec_helper'

describe BuildsController, '#create' do
  it 'ignores confirmation pings' do
    zen_payload = File.read('spec/support/fixtures/zen_payload.json')

    post :create, payload: zen_payload

    expect(response.status).to eq 200
  end
end
