require "rails_helper"

describe ReviewJob do
  describe "#perform" do
    it "calls Reviewer to review violations and file" do
      build_worker = build_stubbed(:build_worker)
      file = double("File")
      violations = double("Violations")
      allow(Reviewer).to receive(:run).with(build_worker, file, violations)

      ReviewJob.perform_now(build_worker, file, violations)

      expect(Reviewer).to have_received(:run)
    end
  end
end
