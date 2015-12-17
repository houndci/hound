require "rails_helper"

describe Violation do
  it { should belong_to(:file_review) }

  describe "#add_messages" do
    it "adds the messages" do
      existing_message = "broken"
      new_message = "it's broken again"
      violation = build(:violation, messages: [existing_message])

      messages = violation.add_message(new_message)

      expect(messages).to match_array([existing_message, new_message])
    end
  end

  describe "#messages" do
    it "returns unique messages" do
      message = "broken"
      all_messages = [message, message]
      violation = build(:violation, messages: all_messages)

      messages = violation.messages

      expect(messages).to match_array([message])
    end
  end

  describe "#messages_count" do
    it "returns the number of violation messages" do
      violation = build(:violation, messages: ["foo", "bar"])

      expect(violation.messages_count).to eq 2
    end
  end

  describe "after create callbacks" do
    it "increments the build's violations count by the number of messages" do
      violation = build(:violation, messages: ["foo", "bar"])

      violation.save

      violation.reload
      expect(violation.file_review.build.violations_count).to eq 2
    end
  end
end
