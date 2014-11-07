require 'spec_helper'

describe Build do
  it { should belong_to :repo }
  it { should validate_presence_of :repo }
  it { should have_many(:violations).dependent(:destroy) }
end

describe Build, '#status' do
  it 'returns passed' do
    build = build(:build)

    expect(build.status).to eq 'passed'
  end

  it 'returns failed' do
    build = build(:build, :failed)

    expect(build.status).to eq 'failed'
  end
end

describe Build, 'on create' do
  it 'generates a UUID' do
    build = create(:build)

    expect(build.uuid).to be_present
  end
end
