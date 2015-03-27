require "rails_helper"

describe Language::JavaScriptLegacyWorker do
  it_behaves_like "Language not moved to IronWorker" do
    let(:content) { "var blahh = 'blahh';" }
    let(:messages) { ["'blahh' is defined but never used."] }
    let(:language) { "java_script" }
  end
end
