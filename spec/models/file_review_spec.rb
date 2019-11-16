require "rails_helper"

describe FileReview do
  describe "associations" do
    it { should belong_to :build }
  end

  describe "#build_violation" do
    context "when line has been changed" do
      it "builds a violations" do
        line = build_line
        file_review = FileReview.new
        violation_message = "violation found!"

        file_review.build_violation(line, violation_message, "foo = bar(1, 2)")
        violation = file_review.violations.first

        expect(file_review.violations.size).to eq 1
        expect(violation.patch_position).to eq line.patch_position
        expect(violation.line_number).to eq line.number
        expect(violation.messages).to eq [violation_message]
        expect(violation.source).to eq "foo = bar(1, 2)"
      end
    end

    context "when line has not been changed" do
      it "does not build a violations" do
        line = build_line(changed: false)
        file_review = FileReview.new

        file_review.build_violation(line, "hello", "foo = bar(1, 2)")

        expect(file_review.violations).to be_empty
      end
    end

    context "with multiple violations on the same line" do
      it "adds messages to the same violation" do
        first_violation_message = "first message"
        other_violation_message = "other message"
        line = build_line
        file_review = FileReview.new

        file_review.build_violation(line, first_violation_message, "foo = bar(1, 2)")
        file_review.build_violation(line, other_violation_message, "foo = bar(1, 2)")
        violation = file_review.violations.first

        expect(file_review.violations.size).to eq 1
        expect(violation.messages).to eq [
          first_violation_message,
          other_violation_message
        ]
      end
    end
  end

  describe "#complete" do
    it "marks it as completed" do
      file_review = FileReview.new

      file_review.complete

      expect(file_review).to be_completed
    end
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

  def build_line(changed: true, number: 1, patch_position: 121)
    double(
      "Line",
      changed?: changed,
      number: number,
      patch_position: patch_position,
    )
  end
end
