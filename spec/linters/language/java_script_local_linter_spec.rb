require "rails_helper"

describe Language::JavaScriptLocalLinter do
  it_behaves_like "Language not moved to IronWorker" do
    let(:content) { "var blahh = 'blahh';" }
    let(:messages) { ["'blahh' is defined but never used."] }
    let(:language) { "javascript" }
  end
end
