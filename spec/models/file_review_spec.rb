require "rails_helper"

describe FileReview do
  describe "associations" do
    it { should belong_to :build }
  end

  describe "validations" do
    it { should validate_presence_of :build }
  end

  describe "#completed?" do
    it "returns true when completed_at is set" do
      file_review = FileReview.new(completed_at: Time.zone.now)

      expect(file_review).to be_completed
    end

    it "returns false when completed_at is nil" do
      file_review = FileReview.new

      expect(file_review).not_to be_completed
    end
  end

  describe "#running?" do
    it "returns true when complete_at is set" do
      file_review = FileReview.new(completed_at: Time.zone.now)

      expect(file_review).not_to be_running
    end

    it "returns false when completed_at is nil" do
      file_review = FileReview.new(completed_at: nil)

      expect(file_review).to be_running
    end
  end
end
