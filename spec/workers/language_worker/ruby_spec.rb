require "rails_helper"

describe LanguageWorker::Ruby do
  it_behaves_like "Language not moved to IronWorker" do
    let(:content) { "def a end;" }
    let(:messages) { ["unexpected token kEND"] }
    let(:language) { "ruby" }
  end
end
