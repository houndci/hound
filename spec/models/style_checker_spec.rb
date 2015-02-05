require "spec_helper"

describe StyleChecker, "#violations" do
  context "for a Ruby file" do
    it "reviews style using Ruby style guide" do
      file = stub_commit_file("good.rb", "code")
      pull_request = stub_pull_request(pull_request_files: [file])
      line = double("Line", changed?: true)
      violation = Violation.new(line: line)
      ruby_style_guide = double("StyleGuide::Ruby", violations_in_file: violation)
      allow(StyleGuide::Ruby).to receive(:new).and_return(ruby_style_guide)

      violation_messages = StyleChecker.new(pull_request).violations

      expect(ruby_style_guide).to have_received(:violations_in_file).with(file)
    end
  end

  context "for a CoffeeScript file" do
    context "with coffee.js file" do
      it "reviews style using CoffeeScript style guide" do
        file = stub_commit_file("good.coffee.js", "code")
        pull_request = stub_pull_request(pull_request_files: [file])
        line = double("Line", changed?: true)
        violation = Violation.new(line: line)
        ruby_style_guide = double("StyleGuide::Ruby", violations_in_file: violation)
        allow(StyleGuide::CoffeeScript).to receive(:new).and_return(ruby_style_guide)

        violation_messages = StyleChecker.new(pull_request).violations

        expect(ruby_style_guide).to have_received(:violations_in_file).with(file)
      end
    end

    context "with .coffee file" do
      it "reviews style using CoffeeScript style guide" do
        file = stub_commit_file("good.coffee", "code")
        pull_request = stub_pull_request(pull_request_files: [file])
        line = double("Line", changed?: true)
        violation = Violation.new(line: line)
        ruby_style_guide = double("StyleGuide::Ruby", violations_in_file: violation)
        allow(StyleGuide::CoffeeScript).to receive(:new).and_return(ruby_style_guide)

        violation_messages = StyleChecker.new(pull_request).violations

        expect(ruby_style_guide).to have_received(:violations_in_file).with(file)
      end
    end
  end

  context "for a JavaScript file" do
    it "reviews style using JavaScript style guide" do
      file = stub_commit_file("good.js", "code")
      pull_request = stub_pull_request(pull_request_files: [file])
      line = double("Line", changed?: true)
      violation = Violation.new(line: line)
      ruby_style_guide = double("StyleGuide::Ruby", violations_in_file: violation)
      allow(StyleGuide::JavaScript).to receive(:new).and_return(ruby_style_guide)

      violation_messages = StyleChecker.new(pull_request).violations

      expect(ruby_style_guide).to have_received(:violations_in_file).with(file)
    end
  end

  context "for a SCSS file" do
    it "reviews style using SCSS style guide" do
      file = stub_commit_file("good.scss", "code")
      pull_request = stub_pull_request(pull_request_files: [file])
      line = double("Line", changed?: true)
      violation = Violation.new(line: line)
      ruby_style_guide = double("StyleGuide::Ruby", violations_in_file: violation)
      allow(StyleGuide::Scss).to receive(:new).and_return(ruby_style_guide)

      violation_messages = StyleChecker.new(pull_request).violations

      expect(ruby_style_guide).to have_received(:violations_in_file).with(file)
    end
  end

  context "for an unsupported file type" do
    it "reviews style with Unsupported style guide" do
      file = stub_commit_file("good.f", "code")
      pull_request = stub_pull_request(pull_request_files: [file])
      line = double("Line", changed?: true)
      violation = Violation.new(line: line)
      ruby_style_guide = double("StyleGuide::Ruby", violations_in_file: violation)
      allow(StyleGuide::Unsupported).to receive(:new).and_return(ruby_style_guide)

      violation_messages = StyleChecker.new(pull_request).violations

      expect(ruby_style_guide).to have_received(:violations_in_file).with(file)
    end
  end

  context "with a removed file" do
    it "does not review style" do
      file = stub_commit_file("good.rb", "code", removed: true)
      pull_request = stub_pull_request(pull_request_files: [file])
      line = double("Line", changed?: true)
      violation = Violation.new(line: line)
      ruby_style_guide = double("StyleGuide::Ruby", violations_in_file: violation)
      allow(StyleGuide::Ruby).to receive(:new).and_return(ruby_style_guide)

      violation_messages = StyleChecker.new(pull_request).violations

      expect(ruby_style_guide).not_to have_received(:violations_in_file)
    end
  end

  private

  def stub_pull_request(options = {})
    head_commit = double("Commit", file_content: "")
    defaults = {
      file_content: "",
      head_commit: head_commit,
      pull_request_files: [],
      repository_owner: "some_org"
    }

    double("PullRequest", defaults.merge(options))
  end

  def stub_commit_file(filename, contents, line = nil, removed: false)
    line ||= Line.new(content: "foo", number: 1, patch_position: 2)
    formatted_contents = "#{contents}\n"
    double(
      filename.split(".").first,
      filename: filename,
      content: formatted_contents,
      removed?: removed,
      line_at: line,
    )
  end
end
