# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Metrics::LineLength, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'Max' => 80 } }

  it "registers an offense for a line that's 81 characters wide" do
    inspect_source(cop, '#' * 81)
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.message).to eq('Line is too long. [81/80]')
    expect(cop.config_to_allow_offenses).to eq('Max' => 81)
  end

  it 'highlights excessive characters' do
    inspect_source(cop, '#' * 80 + 'abc')
    expect(cop.highlights).to eq(['abc'])
  end

  it "accepts a line that's 80 characters wide" do
    inspect_source(cop, '#' * 80)
    expect(cop.offenses).to be_empty
  end

  context 'when AllowURI option is enabled' do
    let(:cop_config) { { 'Max' => 80, 'AllowURI' => true } }

    context 'and all the excessive characters are part of an URL' do
      # This code example is allowed by AllowURI feature itself :).
      let(:source) { <<-END }
        # Some documentation comment...
        # See: https://github.com/bbatsov/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c
      END

      it 'accepts the line' do
        inspect_source(cop, source)
        expect(cop.offenses).to be_empty
      end
    end

    context 'and the excessive characters include a complete URL' do
      # rubocop:disable Metrics/LineLength
      let(:source) { <<-END }
        # See: http://google.com/, http://gmail.com/, https://maps.google.com/, http://plus.google.com/
      END
      # rubocop:enable Metrics/LineLength

      it 'registers an offense for the line' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'highlights all the excessive characters' do
        inspect_source(cop, source)
        expect(cop.highlights).to eq(['http://plus.google.com/'])
      end
    end

    context 'and the excessive characters include part of an URL ' \
            'and another word' do
      # rubocop:disable Metrics/LineLength
      let(:source) { <<-END }
        # See: https://github.com/bbatsov/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c and
        #   http://google.com/
      END
      # rubocop:enable Metrics/LineLength

      it 'registers an offense for the line' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      it 'highlights only the non-URL part' do
        inspect_source(cop, source)
        expect(cop.highlights).to eq([' and'])
      end
    end

    context 'and an error other than URI::InvalidURIError is raised ' \
            'while validating an URI-ish string' do
      let(:cop_config) do
        { 'Max' => 80, 'AllowURI' => true, 'URISchemes' => %w(LDAP) }
      end

      # rubocop:disable Metrics/LineLength
      let(:source) { <<-END }
        xxxxxxxxxxxxxxxxxxxxxxxxxxxxzxxxxxxxxxxx = LDAP::DEFAULT_GROUP_UNIQUE_MEMBER_LIST_KEY
      END
      # rubocop:enable Metrics/LineLength

      it 'does not crash' do
        expect { inspect_source(cop, source) }.not_to raise_error
      end
    end

    context 'and the URL does not have a http(s) scheme' do
      # rubocop:disable Metrics/LineLength
      let(:source) { <<-END }
        xxxxxxxxxxxxxxxxxxxxxxxxxxxxzxxxxxxxxxxx = 'otherprotocol://a.very.long.line.which.violates.LineLength/sadf'
      END
      # rubocop:enable Metrics/LineLength

      it 'rejects the line' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end

      context 'and the scheme has been configured' do
        let(:cop_config) do
          { 'Max' => 80, 'AllowURI' => true, 'URISchemes' => %w(otherprotocol) }
        end

        it 'accepts the line' do
          inspect_source(cop, source)
          expect(cop.offenses).to be_empty
        end
      end
    end
  end

  context 'when AllowURI option is disabled' do
    let(:cop_config) { { 'Max' => 80, 'AllowURI' => false } }

    context 'and all the excessive characters are part of an URL' do
      let(:source) { <<-END }
        # See: https://github.com/bbatsov/rubocop/commit/3b48d8bdf5b1c2e05e35061837309890f04ab08c
      END

      it 'registers an offense for the line' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end
    end
  end
end
