require "rails_helper"

describe ReviewJob do
  describe "#perform" do
    it "runs Review" do
      build_worker = build_stubbed(:build_worker)
      file = double("File")
      violations = double("Violations")
      allow(Review).to receive(:run).with(build_worker, file, violations)

      ReviewJob.perform_now(build_worker, file, violations)

      expect(Review).to have_received(:run)
    end
  end
end
