require "spec_helper"

describe Linter::Credo do
  it_behaves_like "a linter" do
    let(:lintable_files) { %w(foo.ex foo.exs) }
    let(:not_lintable_files) { %w(foo.txt) }
  end
end
