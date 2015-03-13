require "spec_helper"

describe LanguageWorker::JavaScript do
  it_behaves_like "Language not moved to IronWorker" do
    let(:content) { "var blahh = 'blahh';" }
    let(:messages) { ["'blahh' is defined but never used."] }
    let(:language) { "java_script" }
  end
end
