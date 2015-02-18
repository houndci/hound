require "spec_helper"

describe RubyViolations do
  describe "#count" do
    it "returns counts of each violation message" do
      repo = create(:repo)
      build = create(:build, repo: repo)
      create(:violation, build: build, messages: ["Test message!"])
      create(
        :violation,
        build: build,
        messages: ["Line is too long. [81/80]", "Test message!"]
      )

      violations = RubyViolations.new([repo])

      expect(violations.count).to eq(
        [
          {
            message: "Test message!",
            count: 2
          },
          {
            message: "Line is too long. [81/80]",
            count: 1
          }
        ]
      )
    end
  end
end
