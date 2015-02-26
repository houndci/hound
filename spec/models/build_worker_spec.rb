require "spec_helper"

describe BuildWorker, type: :model do
  it { should validate_presence_of :build }
  it { should belong_to :build }
end
