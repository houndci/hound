require "fast_spec_helper"
require "app/models/violation"
require "app/models/violations"

describe Violations do
  describe "#push" do
    context "when passing one violation" do
      it "adds one violation" do
        violation = build_violation(message: "wrong quotes")
        violations = Violations.new

        violations.push(violation)

        expect(violations.count).to eq 1
      end
    end

    context "when passing multiple violations" do
      it "adds multiple violations" do
        violation1 = build_violation(line_number: 2, message: "wrong quotes")
        violation2 = build_violation(line_number: 17, message: "extra newline")
        violations = Violations.new

        violations.push(violation1, violation2)

        expect(violations.count).to eq 2
        expect(violations.flat_map(&:messages)).
          to eq ["wrong quotes", "extra newline"]
      end
    end
  end
  describe "#uniq" do
    context "when collection is empty" do
      it "adds new violation" do
        violations = violations_with_messages(["hello world"])

        expect(violations.count).to eq 1
      end
    end

    context "when violation already exists on the same line" do
      it "adds message to the violation" do
        violations = violations_with_messages(["foo", "bar"])

        expect(violations.count).to eq 1
        expect(violations.first.messages).to eq ["foo", "bar"]
      end
    end
  end

  def violations_with_messages(messages)
    violations = messages.map { |message| build_violation(message: message) }
    Violations.new(*violations)
  end

  def build_violation(options = {})
    line_number = options.fetch(:line_number, 1)
    message = options.fetch(:message, "illegal syntax")
    line = double("Line", changed?: true)
    file = double("CommitFile", filename: "foo.rb", line_at: line)
    Violation.new(file, line_number, message)
  end
end
