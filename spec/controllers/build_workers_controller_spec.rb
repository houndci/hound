require "rails_helper"

describe BuildWorkersController do
  describe "#update" do
    context "when authorized" do
      it "returns status 201" do
        allow(ReviewJob).to receive(:perform_later)
        file = double("File")
        violations = double("ViolationsAttrs")
        build_worker = create(:build_worker)
        authorized_headers_for_build_worker

        put(
          :update,
          id: build_worker.id,
          violations: violations,
          file: file,
          format: :json,
        )

        expect(response.status).to eq 201
      end

      it "dispatches a ReviewJob" do
        allow(ReviewJob).to receive(:perform_later)
        file = double("File")
        violations = double("ViolationsAttrs")
        build_worker = create(:build_worker)
        authorized_headers_for_build_worker

        put(
          :update,
          id: build_worker.id,
          violations: violations,
          file: file,
          format: :json,
        )

        expect(ReviewJob).
          to have_received(:perform_later).
          with(build_worker, file, violations)
      end
    end

    context "when not authorized" do
      it "responds with 401" do
        put :update, id: 1, format: :json

        expect(response.status).to eq(401)
      end
    end
  end
end
