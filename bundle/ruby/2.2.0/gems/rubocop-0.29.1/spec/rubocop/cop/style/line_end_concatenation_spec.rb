# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::LineEndConcatenation do
  subject(:cop) { described_class.new }

  it 'registers an offense for string concat at line end' do
    inspect_source(cop,
                   ['top = "test" +',
                    '"top"'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['+'])
  end

  it 'registers an offense for string concat with << at line end' do
    inspect_source(cop,
                   ['top = "test" <<',
                    '"top"'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['<<'])
  end

  it 'registers an offense for string concat with << and \ at line ends' do
    inspect_source(cop,
                   ['top = "test " \\',
                    '"foo" <<',
                    '"bar"'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for dynamic string concat at line end' do
    inspect_source(cop,
                   ['top = "test#{x}" +',
                    '"top"'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for dynamic string concat with << at line end' do
    inspect_source(cop,
                   ['top = "test#{x}" <<',
                    '"top"'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers multiple offenses when there are chained << methods' do
    inspect_source(cop,
                   ['top = "test#{x}" <<',
                    '"top" <<',
                    '"ubertop"'])
    expect(cop.offenses.size).to eq(2)
  end

  it 'registers multiple offenses when there are chained concatenations' do
    inspect_source(cop,
                   ['top = "test#{x}" +',
                    '"top" +',
                    '"foo"'])
    expect(cop.offenses.size).to eq(2)
  end

  it 'registers multiple offenses when there are chained concatenations' \
     'combined with << calls' do
    inspect_source(cop,
                   ['top = "test#{x}" <<',
                    '"top" +',
                    '"foo" <<',
                    '"bar"'])
    expect(cop.offenses.size).to eq(3)
  end

  it 'accepts string concat on the same line' do
    inspect_source(cop,
                   'top = "test" + "top"')
    expect(cop.offenses).to be_empty
  end

  it 'accepts string concat with a return value of method on a string' do
    inspect_source(cop,
                   [
                     # What we want here is 'content   ', not '
                     # content content content '.
                     'content_and_three_spaces = "content" +',
                     '  " " * 3',
                     # Method call with dot on a string literal.
                     "a_thing = 'a ' +",
                     "  'gniht'.reverse",
                     # Formatting operator.
                     "output = 'value: ' +",
                     "  '%d' % value",
                     # Index operator.
                     "'letter: ' +",
                     "  'abcdefghij'[ix]"
                   ])
    expect(cop.offenses).to be_empty
  end

  it 'accepts string concat with a return value of method on an interpolated ' \
     'string' do
    source = <<-END
      x3a = 'x' +
        "\#{'a' + "\#{3}"}".reverse
    END
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts string concat at line end when followed by comment' do
    inspect_source(cop,
                   ['top = "test" + # something',
                    '"top"'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts string concat at line end when followed by a comment line' do
    inspect_source(cop,
                   ['top = "test" +',
                    '# something',
                    '"top"'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts string concat at line end when % literals are involved' do
    inspect_source(cop,
                   ['top = %(test) +',
                    '"top"'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts string concat at line end for special strings like __FILE__' do
    inspect_source(cop,
                   ['top = __FILE__ +',
                    '"top"'])
    expect(cop.offenses).to be_empty
  end

  it 'registers offenses only for the appropriate lines in chained concats' do
    # only the last concatenation is an offense
    inspect_source(cop,
                   ['top = "test#{x}" + # comment',
                    '"foo" +',
                    '%(bar) +',
                    '"baz" +',
                    '"qux"'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'autocorrects in the simple case by replacing + with \\' do
    corrected = autocorrect_source(cop,
                                   ['top = "test" +',
                                    '"top"'])
    expect(corrected).to eq ['top = "test" \\', '"top"'].join("\n")
  end

  it 'autocorrects for chained concatenations and << calls' do
    corrected = autocorrect_source(cop,
                                   ['top = "test#{x}" <<',
                                    '"top" +',
                                    '"ubertop" <<',
                                    '"foo"'])

    expect(corrected).to eq ['top = "test#{x}" \\',
                             '"top" \\',
                             '"ubertop" \\',
                             '"foo"'].join("\n")
  end

  it 'autocorrects only the lines that should be autocorrected' do
    corrected = autocorrect_source(cop,
                                   ['top = "test#{x}" <<',
                                    '"top" + # comment',
                                    '"foo" +',
                                    '"bar" +',
                                    '%(baz) +',
                                    '"qux"'])

    expect(corrected).to eq ['top = "test#{x}" \\',
                             '"top" + # comment',
                             '"foo" \\',
                             '"bar" +',
                             '%(baz) +',
                             '"qux"'].join("\n")
  end
end
