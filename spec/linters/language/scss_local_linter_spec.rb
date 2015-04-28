require "rails_helper"

describe Language::ScssLocalLinter do
  it_behaves_like "Language not moved to IronWorker" do
    let(:content) { ".a { display: 'none'; }\n" }
    let(:messages) { ["Prefer double-quoted strings"] }
    let(:language) { "scss" }
  end
end
