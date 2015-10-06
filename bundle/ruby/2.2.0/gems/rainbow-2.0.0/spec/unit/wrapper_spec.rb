require 'spec_helper'
require 'rainbow/wrapper'

module Rainbow
  describe Wrapper do

    let(:wrapper) { described_class.new(enabled) }

    describe '#wrap' do
      subject { wrapper.wrap('hello') }

      context "when wrapping is enabled" do
        let(:enabled) { true }

        it { should eq('hello') }
        it { should be_kind_of(Rainbow::Presenter) }
      end

      context "when wrapping is disabled" do
        let(:enabled) { false }

        it { should eq('hello') }
        it { should be_kind_of(Rainbow::NullPresenter) }
      end
    end

  end
end
