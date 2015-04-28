require "rails_helper"

describe BuildWorker do
  it { should validate_presence_of :build }
  it { should belong_to :build }

  describe "#completed?" do
    it "returns true where completed_at is set" do
      build_worker = BuildWorker.new(completed_at: Time.now)

      expect(build_worker.completed?).to eq true
    end

    it "returns false where completed_at is nil" do
      build_worker = BuildWorker.new

      expect(build_worker.completed?).to eq false
    end
  end

  describe "#running?" do
    it "returns true where complete_at is nil" do
      build_worker = BuildWorker.new(completed_at: Time.now)

      expect(build_worker.running?).to eq false
    end

    it "returns false where completed_at is set" do
      build_worker = BuildWorker.new(completed_at: nil)

      expect(build_worker.running?).to eq true
    end
  end
end
