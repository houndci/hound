require "spec_helper"

describe BuildWorkersController do
  describe "#update" do
    context "given an uncompleted build", :run_background_jobs_immediately do
      it "completes the build" do
        build_worker = create(:build_worker)

        put :update, id: build_worker.id, format: :json

        expect(build_worker.reload.completed_at?).to eq true
      end
    end

    context "given an completed build" do
      it "does not complete the build" do
        build_worker = create(
          :build_worker,
          :completed,
          completed_at: 1.day.ago,
        )

        put :update, id: build_worker.id, format: :json

        expect(response.status).to eq 412
        expect(build_worker.completed_at).to be < Time.now
        expect(json_body["error"]).to eq(
          "BuildWorker##{build_worker.id} has already been finished"
        )
      end
    end

    it "dispatches a ReviewJob" do
      allow(ReviewJob).to receive(:perform_later)
      file = double("File")
      violations = double("Violations")
      build_worker = create(:build_worker)

      put(
        :update,
        id: build_worker.id,
        violations: violations,
        file: file,
        format: :json
      )

      expect(ReviewJob).
        to have_received(:perform_later).with(build_worker, file, violations)
    end
  end
end
