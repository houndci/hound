require 'fast_spec_helper'
require 'app/models/rule'
require 'app/models/whitespace_rule'

describe WhitespaceRule, '#violated?' do
  context 'with predicate methods' do
    it 'returns false' do
      code_snippet = 'def valid?'

      expect(code_snippet).not_to violate(WhitespaceRule)
    end
  end

  context 'with trailing whitespace' do
    it 'returns true' do
      code_snippet = 'def method_name  '

      expect(code_snippet).to violate(WhitespaceRule)
    end
  end

  context 'without trailing whitespace' do
    it 'returns false' do
      code_snippet = %(message = 'Warning! Something failed.')

      expect(code_snippet).not_to violate(WhitespaceRule)
    end
  end

  context 'with two whitespaces' do
    it 'returns true' do
      code_snippet = 'hello  world'

      expect(code_snippet).to violate(WhitespaceRule)
    end
  end

  context 'with padded operators' do
    context 'and valid whitespace' do
      it 'returns false' do
        code_snippet = 'hello = 1 + 2'

        expect(code_snippet).not_to violate(WhitespaceRule)
      end
    end

    context 'and extra whitespace' do
      it 'returns true' do
        code_snippet = 'hello =  some_method(2)'

        expect(code_snippet).to violate(WhitespaceRule)
      end
    end

    context 'when path to file' do
      it 'returns false' do
        code_snippet = %(require 'app/models/user')

        expect(code_snippet).not_to violate(WhitespaceRule)
      end
    end

    context 'when dashed attribute' do
      it 'returns false' do
        code_snippet = %(data-attribute)

        expect(code_snippet).not_to violate(WhitespaceRule)
      end
    end
  end

  context 'with double-character operator' do
    context 'and no whitespace' do
      it 'returns true' do
        code_snippet = 'true&&false'

        expect(code_snippet).to violate(WhitespaceRule)
      end
    end

    context 'and surrounded by whitespace' do
      it 'returns false' do
        code_snippet = 'true && false'

        expect(code_snippet).not_to violate(WhitespaceRule)
      end
    end
  end

  context 'with comma' do
    context 'and no whitespace after' do
      it 'returns true' do
        code_snippet = 'names = [:bob,:joe,:tom]'

        expect(code_snippet).to violate(WhitespaceRule)
      end
    end

    context 'and whitespace after' do
      it 'returns true' do
        code_snippet = 'names = [:bob, :joe, :tom]'

        expect(code_snippet).to violate(WhitespaceRule)
      end
    end
  end

  context 'with colon' do
    context 'and no whitespace after' do
      it 'returns true' do
        code_snippet = %({ bob:'Robert', joe:'Joseph' })

        expect(code_snippet).to violate(WhitespaceRule)
      end
    end

    context 'and whitespace after' do
      it 'returns false' do
        code_snippet = %({ bob: 'Robert', joe: 'Joseph' })

        expect(code_snippet).not_to violate(WhitespaceRule)
      end
    end

    context 'and no whitespace in ternary expression' do
      it 'returns true' do
        code_snippet = 'my_var ? true:false'

        expect(code_snippet).to violate(WhitespaceRule)
      end
    end
  end

  context 'with double colon' do
    context 'and whitespace after' do
      it 'returns true' do
        code_snippet = 'MyModule :: MyClass'

        expect(code_snippet).to violate(WhitespaceRule)
      end
    end

    context 'and no whitespace after' do
      it 'returns false' do
        code_snippet = 'MyModule::MyClass'

        expect(code_snippet).not_to violate(WhitespaceRule)
      end
    end
  end
end
