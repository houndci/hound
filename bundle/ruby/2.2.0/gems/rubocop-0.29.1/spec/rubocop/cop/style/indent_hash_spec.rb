# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::IndentHash do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    supported_styles = {
      'SupportedStyles' => %w(special_inside_parentheses consistent)
    }
    RuboCop::Config.new('Style/AlignHash' => align_hash_config,
                        'Style/IndentHash' =>
                        cop_config.merge(supported_styles),
                        'Style/IndentationWidth' => { 'Width' => 2 })
  end
  let(:align_hash_config) do
    {
      'Enabled' => true,
      'EnforcedColonStyle' => 'key',
      'EnforcedHashRocketStyle' => 'key'
    }
  end
  let(:cop_config) { { 'EnforcedStyle' => 'special_inside_parentheses' } }

  shared_examples 'right brace' do
    it 'registers an offense for incorrectly indented }' do
      inspect_source(cop,
                     ['a << {',
                      '  }'])
      expect(cop.highlights).to eq(['}'])
      expect(cop.messages)
        .to eq(['Indent the right brace the same as the start of the line ' \
                'where the left brace is.'])
      expect(cop.config_to_allow_offenses).to eq(nil)
    end
  end

  context 'when the AlignHash style is separator for :' do
    let(:align_hash_config) do
      {
        'Enabled' => true,
        'EnforcedColonStyle' => 'separator',
        'EnforcedHashRocketStyle' => 'key'
      }
    end

    it 'accepts correctly indented first pair' do
      inspect_source(cop,
                     ['a << {',
                      '    a: 1,',
                      '  aaa: 222',
                      '}'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for incorrectly indented first pair with :' do
      inspect_source(cop,
                     ['a << {',
                      '       a: 1,',
                      '     aaa: 222',
                      '}'])
      expect(cop.highlights).to eq(['a: 1'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    include_examples 'right brace'
  end

  context 'when the AlignHash style is separator for =>' do
    let(:align_hash_config) do
      {
        'Enabled' => true,
        'EnforcedColonStyle' => 'key',
        'EnforcedHashRocketStyle' => 'separator'
      }
    end

    it 'accepts correctly indented first pair' do
      inspect_source(cop,
                     ['a << {',
                      "    'a' => 1,",
                      "  'aaa' => 222",
                      '}'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for incorrectly indented first pair with =>' do
      inspect_source(cop,
                     ['a << {',
                      "   'a' => 1,",
                      " 'aaa' => 222",
                      '}'])
      expect(cop.highlights).to eq(["'a' => 1"])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    include_examples 'right brace'
  end

  context 'when hash is operand' do
    it 'accepts correctly indented first pair' do
      inspect_source(cop,
                     ['a << {',
                      '  a: 1',
                      '}'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for incorrectly indented first pair' do
      inspect_source(cop,
                     ['a << {',
                      ' a: 1',
                      '}'])
      expect(cop.highlights).to eq(['a: 1'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'auto-corrects incorrectly indented first pair' do
      corrected = autocorrect_source(cop, ['a << {',
                                           ' a: 1',
                                           '}'])
      expect(corrected).to eq ['a << {',
                               '  a: 1',
                               '}'].join("\n")
    end

    include_examples 'right brace'
  end

  context 'when hash is argument to setter' do
    it 'accepts correctly indented first pair' do
      inspect_source(cop,
                     ['   config.rack_cache = {',
                      '     :metastore => "rails:/",',
                      '     :entitystore => "rails:/",',
                      '     :verbose => false',
                      '   }'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for incorrectly indented first pair' do
      inspect_source(cop,
                     ['   config.rack_cache = {',
                      '   :metastore => "rails:/",',
                      '   :entitystore => "rails:/",',
                      '   :verbose => false',
                      '   }'])
      expect(cop.highlights).to eq([':metastore => "rails:/"'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end
  end

  context 'when hash is right hand side in assignment' do
    it 'registers an offense for incorrectly indented first pair' do
      inspect_source(cop, ['a = {',
                           '    a: 1,',
                           '  b: 2,',
                           ' c: 3',
                           '}'])
      expect(cop.messages)
        .to eq(['Use 2 spaces for indentation in a hash, relative to the ' \
                'start of the line where the left curly brace is.'])
      expect(cop.highlights).to eq(['a: 1'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'auto-corrects incorrectly indented first pair' do
      corrected = autocorrect_source(cop, ['a = {',
                                           '    a: 1,',
                                           '  b: 2,',
                                           ' c: 3',
                                           '}'])
      expect(corrected).to eq ['a = {',
                               '  a: 1,',
                               '  b: 2,',
                               ' c: 3',
                               '}'].join("\n")
    end

    it 'accepts correctly indented first pair' do
      inspect_source(cop,
                     ['a = {',
                      '  a: 1',
                      '}'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts several pairs per line' do
      inspect_source(cop,
                     ['a = {',
                      '  a: 1, b: 2',
                      '}'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts a first pair on the same line as the left brace' do
      inspect_source(cop,
                     ['a = { "a" => 1,',
                      '      "b" => 2 }'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts single line hash' do
      inspect_source(cop,
                     'a = { a: 1, b: 2 }')
      expect(cop.offenses).to be_empty
    end

    it 'accepts an empty hash' do
      inspect_source(cop,
                     'a = {}')
      expect(cop.offenses).to be_empty
    end
  end

  context 'when hash is method argument' do
    context 'and arguments are surrounded by parentheses' do
      context 'and EnforcedStyle is special_inside_parentheses' do
        it 'accepts special indentation for first argument' do
          inspect_source(cop,
                         # Only the function calls are affected by
                         # EnforcedStyle setting. Other indentation shall be
                         # the same regardless of EnforcedStyle.
                         ['h = {',
                          '  a: 1',
                          '}',
                          'func({',
                          '       a: 1',
                          '     })',
                          'func(x, {',
                          '       a: 1',
                          '     })',
                          'h = { a: 1',
                          '}',
                          'func({ a: 1',
                          '     })',
                          'func(x, { a: 1',
                          '     })'])
          expect(cop.offenses).to be_empty
        end

        it 'registers an offense for incorrect indentation' do
          inspect_source(cop,
                         ['func({',
                          '  a: 1',
                          '})'])
          expect(cop.messages)
            .to eq(['Use 2 spaces for indentation in a hash, relative to the' \
                    ' first position after the preceding left parenthesis.',

                    'Indent the right brace the same as the first position ' \
                    'after the preceding left parenthesis.'])
          expect(cop.config_to_allow_offenses)
            .to eq('EnforcedStyle' => 'consistent')
        end

        it 'auto-corrects incorrectly indented first pair' do
          corrected = autocorrect_source(cop, ['func({',
                                               '  a: 1',
                                               '})'])
          expect(corrected).to eq ['func({',
                                   '       a: 1',
                                   '     })'].join("\n")
        end

        it 'accepts special indentation for second argument' do
          inspect_source(cop,
                         ['body.should have_tag("input", :attributes => {',
                          '                       :name => /q\[(id_eq)\]/ })'])
          expect(cop.offenses).to be_empty
        end

        it 'accepts normal indentation for hash within hash' do
          inspect_source(cop,
                         ['scope = scope.where(',
                          '  klass.table_name => {',
                          '    reflection.type => model.base_class.sti_name',
                          '  }',
                          ')'])
          expect(cop.offenses).to be_empty
        end
      end

      context 'and EnforcedStyle is consistent' do
        let(:cop_config) { { 'EnforcedStyle' => 'consistent' } }

        it 'accepts normal indentation for first argument' do
          inspect_source(cop,
                         # Only the function calls are affected by
                         # EnforcedStyle setting. Other indentation shall be
                         # the same regardless of EnforcedStyle.
                         ['h = {',
                          '  a: 1',
                          '}',
                          'func({',
                          '  a: 1',
                          '})',
                          'func(x, {',
                          '  a: 1',
                          '})',
                          'h = { a: 1',
                          '}',
                          'func({ a: 1',
                          '})',
                          'func(x, { a: 1',
                          '})'])
          expect(cop.offenses).to be_empty
        end

        it 'registers an offense for incorrect indentation' do
          inspect_source(cop,
                         ['func({',
                          '       a: 1',
                          '     })'])
          expect(cop.messages)
            .to eq(['Use 2 spaces for indentation in a hash, relative to the' \
                    ' start of the line where the left curly brace is.',

                    'Indent the right brace the same as the start of the ' \
                    'line where the left brace is.'])
          expect(cop.config_to_allow_offenses)
            .to eq('EnforcedStyle' => 'special_inside_parentheses')
        end

        it 'accepts normal indentation for second argument' do
          inspect_source(cop,
                         ['body.should have_tag("input", :attributes => {',
                          '  :name => /q\[(id_eq)\]/ })'])
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'and argument are not surrounded by parentheses' do
      it 'accepts braceless hash' do
        inspect_source(cop,
                       'func a: 1, b: 2')
        expect(cop.offenses).to be_empty
      end

      it 'accepts single line hash with braces' do
        inspect_source(cop,
                       'func x, { a: 1, b: 2 }')
        expect(cop.offenses).to be_empty
      end

      it 'accepts a correctly indented multi-line hash with braces' do
        inspect_source(cop,
                       ['func x, {',
                        '  a: 1, b: 2 }'])
        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for incorrectly indented multi-line hash ' \
         'with braces' do
        inspect_source(cop,
                       ['func x, {',
                        '       a: 1, b: 2 }'])
        expect(cop.messages)
          .to eq(['Use 2 spaces for indentation in a hash, relative to the ' \
                  'start of the line where the left curly brace is.'])
        expect(cop.highlights).to eq(['a: 1'])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end
    end
  end
end
