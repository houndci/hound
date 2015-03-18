require "rails_helper"

describe Subscription do
  context "when creating a duplicate subscription for a repo" do
    it "raises a unique constraint error" do
      create(:subscription, repo_id: 1)

      expect { create(:subscription, repo_id: 1) }.
        to raise_error ActiveRecord::RecordNotUnique
    end
  end

  context "when existing subscripion is deleted" do
    it "does not raise an error" do
      create(:subscription, repo_id: 1, deleted_at: 1.day.ago)

      expect { create(:subscription, repo_id: 1) }.not_to raise_error
    end
  end
end
