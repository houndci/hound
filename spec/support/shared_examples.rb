RSpec.shared_examples "a linter" do
  describe ".can_lint?" do
    it "rejects files based on FILE_REGEXP" do
      not_lintable_files.each do |file|
        no_lint = described_class.can_lint?(file)

        expect(no_lint).to eq false
      end
    end

    it "accepts files based on FILE_REGEXP" do
      lintable_files.each do |file|
        yes_lint = described_class.can_lint?(file)

        expect(yes_lint).to eq true
      end
    end
  end
end
