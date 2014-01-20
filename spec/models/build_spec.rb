require 'spec_helper'

describe Build do
  it { should belong_to :repo }
  it { should validate_presence_of :repo }
  it { should serialize(:violations).as(Array) }
end

describe Build, '#status' do
  it 'returns passed' do
    build = Build.new(violations: [])

    expect(build.status).to eq 'passed'
  end

  it 'returns failed' do
    build = Build.new(violations: ['something'])

    expect(build.status).to eq 'failed'
  end
end

describe Build, 'on create' do
  it 'generates a UUID' do
    build = create(:build)

    expect(build.uuid).to be_present
  end
end

describe Build, '.find_by_uuid' do
  it 'finds Build by UUID' do
    build = create(:build)

    found_build = Build.find_by_uuid(build.uuid)

    expect(found_build).to eq build
  end
end
