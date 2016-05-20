# encoding: utf-8

require 'spec_helper'

module RuboCop
  class Runner
    attr_writer :errors # Needed only for testing.
  end
end

describe RuboCop::Runner, :isolated_environment do
  include FileHelper

  let(:formatter_output_path) { 'formatter_output.txt' }
  let(:formatter_output) { File.read(formatter_output_path) }

  before do
    create_file('example.rb', source)
  end

  describe '#run' do
    let(:options) { { formatters: [['progress', formatter_output_path]] } }
    subject(:runner) { described_class.new(options, RuboCop::ConfigStore.new) }
    context 'if there are no offenses in inspected files' do
      let(:source) { <<-END.strip_indent }
        # coding: utf-8
        def valid_code
        end
      END

      it 'returns true' do
        expect(runner.run([])).to be true
      end
    end

    context 'if there is an offense in an inspected file' do
      let(:source) { <<-END.strip_indent }
        # coding: utf-8
        def INVALID_CODE
        end
      END

      it 'returns false' do
        expect(runner.run([])).to be false
      end

      it 'sends the offense to a formatter' do
        runner.run([])
        expect(formatter_output).to eq <<-END.strip_indent
          Inspecting 1 file
          C

          Offenses:

          example.rb:2:5: C: Use snake_case for method names.
          def INVALID_CODE
              ^^^^^^^^^^^^

          1 file inspected, 1 offense detected
        END
      end
    end
  end

  describe '#run with cops autocorrecting each-other' do
    let(:options) do
      {
        auto_correct: true,
        formatters: [['progress', formatter_output_path]]
      }
    end

    subject(:runner) do
      runner_class = Class.new(RuboCop::Runner) do
        def mobilized_cop_classes(_config)
          [
            RuboCop::Cop::Test::ClassMustBeAModuleCop,
            RuboCop::Cop::Test::ModuleMustBeAClassCop
          ]
        end
      end
      runner_class.new(options, RuboCop::ConfigStore.new)
    end

    context 'if there is an offense in an inspected file' do
      let(:source) { <<-END.strip_indent }
        # coding: utf-8
        class Klass
        end
      END

      it 'aborts because of an infinite loop' do
        expect do
          runner.run([])
        end.to raise_error RuboCop::Runner::InfiniteCorrectionLoop
      end
    end
  end
end
