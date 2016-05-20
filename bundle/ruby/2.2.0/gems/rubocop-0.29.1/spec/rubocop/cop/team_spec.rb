# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Team do
  subject(:team) { described_class.new(cop_classes, config, options) }
  let(:cop_classes) { RuboCop::Cop::Cop.non_rails }
  let(:config) { RuboCop::ConfigLoader.default_configuration }
  let(:options) { nil }

  describe '#autocorrect?' do
    subject { team.autocorrect? }

    context 'when the option argument of .new is omitted' do
      subject { described_class.new(cop_classes, config).autocorrect? }
      it { should be_falsey }
    end

    context 'when { auto_correct: true } is passed to .new' do
      let(:options) { { auto_correct: true } }
      it { should be_truthy }
    end
  end

  describe '#debug?' do
    subject { team.debug? }

    context 'when the option argument of .new is omitted' do
      subject { described_class.new(cop_classes, config).debug? }
      it { should be_falsey }
    end

    context 'when { debug: true } is passed to .new' do
      let(:options) { { debug: true } }
      it { should be_truthy }
    end
  end

  describe '#inspect_file', :isolated_environment do
    include FileHelper

    let(:file_path) { '/tmp/example.rb' }
    let(:offenses) do
      team.inspect_file(RuboCop::ProcessedSource.from_file(file_path))
    end

    before do
      create_file(file_path, [
        '#' * 90,
        'puts test;'
      ])
    end

    it 'returns offenses' do
      expect(offenses).not_to be_empty
      expect(offenses.all? { |o| o.is_a?(RuboCop::Cop::Offense) }).to be_truthy
    end

    context 'when Parser reports non-fatal warning for the file' do
      before do
        create_file(file_path, [
          '# encoding: utf-8',
          '#' * 90,
          'puts *test'
        ])
      end

      let(:cop_names) { offenses.map(&:cop_name) }

      it 'returns Parser warning offenses' do
        expect(cop_names).to include('Lint/AmbiguousOperator')
      end

      it 'returns offenses from cops' do
        expect(cop_names).to include('Metrics/LineLength')
      end
    end

    context 'when autocorrection is enabled' do
      let(:options) { { auto_correct: true } }

      before do
        create_file(file_path, [
          '# encoding: utf-8',
          'puts "string"'
        ])
      end

      it 'does autocorrection' do
        team.inspect_file(RuboCop::ProcessedSource.from_file(file_path))
        corrected_source = File.read(file_path)
        expect(corrected_source).to eq([
          '# encoding: utf-8',
          "puts 'string'",
          ''
        ].join("\n"))
      end

      it 'still returns offenses' do
        expect(offenses.first.cop_name).to eq('Style/StringLiterals')
      end
    end
  end

  describe '#cops' do
    subject(:cops) { team.cops }

    it 'returns cop instances' do
      expect(cops).not_to be_empty
      expect(cops.all? { |c| c.is_a?(RuboCop::Cop::Cop) }).to be_truthy
    end

    context 'when only some cop classes are passed to .new' do
      let(:cop_classes) do
        [RuboCop::Cop::Lint::Void, RuboCop::Cop::Metrics::LineLength]
      end

      it 'returns only instances of the classes' do
        expect(cops.size).to eq(2)
        cops.sort! { |a, b| a.name <=> b.name }
        expect(cops[0].name).to eq('Lint/Void')
        expect(cops[1].name).to eq('Metrics/LineLength')
      end
    end

    context 'when some classes are disabled with config' do
      let(:disabled_config) do
        %w(
          Lint/Void
          Metrics/LineLength
        ).each_with_object({}) do |cop_name, accum|
          accum[cop_name] = { 'Enabled' => false }
        end
      end
      let(:config) do
        RuboCop::ConfigLoader.merge_with_default(disabled_config, '')
      end
      let(:cop_names) { cops.map(&:name) }

      it 'does not return instances of the classes' do
        expect(cops).not_to be_empty
        expect(cop_names).not_to include('Lint/Void')
        expect(cop_names).not_to include('Metrics/LineLength')
      end
    end
  end

  describe '#forces' do
    subject(:forces) { team.forces }
    let(:cop_classes) { RuboCop::Cop::Cop.non_rails }

    it 'returns force instances' do
      expect(forces).not_to be_empty

      forces.each do |force|
        expect(force).to be_a(RuboCop::Cop::Force)
      end
    end

    context 'when a cop joined a force' do
      let(:cop_classes) { [RuboCop::Cop::Lint::UselessAssignment] }

      it 'returns the force' do
        expect(forces.size).to eq(1)
        expect(forces.first).to be_a(RuboCop::Cop::VariableForce)
      end
    end

    context 'when multiple cops joined a same force' do
      let(:cop_classes) do
        [
          RuboCop::Cop::Lint::UselessAssignment,
          RuboCop::Cop::Lint::ShadowingOuterLocalVariable
        ]
      end

      it 'returns only one force instance' do
        expect(forces.size).to eq(1)
      end
    end

    context 'when no cops joined force' do
      let(:cop_classes) { [RuboCop::Cop::Style::For] }

      it 'returns nothing' do
        expect(forces).to be_empty
      end
    end
  end
end
