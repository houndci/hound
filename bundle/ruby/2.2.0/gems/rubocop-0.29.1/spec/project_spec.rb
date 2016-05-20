# encoding: utf-8

require 'spec_helper'

describe 'RuboCop Project' do
  describe 'default configuration file' do
    let(:cop_names) { RuboCop::Cop::Cop.all.map(&:cop_name) }

    subject(:default_config) do
      RuboCop::ConfigLoader.load_file('config/default.yml')
    end

    it 'has configuration for all cops' do
      expect(default_config.keys.sort).to eq((['AllCops'] + cop_names).sort)
    end

    it 'has a nicely formatted description for all cops' do
      cop_names.each do |name|
        description = default_config[name]['Description']
        expect(description).not_to be_nil
        expect(description).not_to include("\n")
      end
    end
  end

  describe 'changelog' do
    subject(:changelog) do
      path = File.join(File.dirname(__FILE__), '..', 'CHANGELOG.md')
      File.read(path)
    end

    it 'has link definitions for all implicit links' do
      implicit_link_names = changelog.scan(/\[([^\]]+)\]\[\]/).flatten.uniq
      implicit_link_names.each do |name|
        expect(changelog).to include("[#{name}]: http")
      end
    end

    describe 'entry' do
      subject(:entries) { lines.grep(/^\*/).map(&:chomp) }
      let(:lines) { changelog.each_line }

      it 'has a whitespace between the * and the body' do
        entries.each do |entry|
          expect(entry).to match(/^\* \S/)
        end
      end

      context 'after version 0.14.0' do
        let(:lines) do
          changelog.each_line.take_while do |line|
            !line.start_with?('## 0.14.0')
          end
        end

        it 'has a link to the contributors at the end' do
          entries.each do |entry|
            expect(entry).to match(/\(\[@\S+\]\[\](?:, \[@\S+\]\[\])*\)$/)
          end
        end
      end

      describe 'link to related issue' do
        let(:issues) do
          entries.map do |entry|
            entry.match(/\[(?<number>[#\d]+)\]\((?<url>[^\)]+)\)/)
          end.compact
        end

        it 'has an issue number prefixed with #' do
          issues.each do |issue|
            expect(issue[:number]).to match(/^#\d+$/)
          end
        end

        it 'has a valid URL' do
          issues.each do |issue|
            number = issue[:number].gsub(/\D/, '')
            pattern = %r{^https://github\.com/bbatsov/rubocop/(?:issues|pull)/#{number}$} # rubocop:disable Metrics/LineLength
            expect(issue[:url]).to match(pattern)
          end
        end

        it 'has a colon and a whitespace at the end' do
          entries_including_issue_link = entries.select do |entry|
            entry.match(/^\*\s*\[/)
          end

          entries_including_issue_link.each do |entry|
            expect(entry).to include('): ')
          end
        end
      end

      describe 'body' do
        let(:bodies) do
          entries.map do |entry|
            entry
              .gsub(/`[^`]+`/, '``')
              .sub(/^\*\s*(?:\[.+?\):\s*)?/, '')
              .sub(/\s*\([^\)]+\)$/, '')
          end
        end

        it 'does not start with a lower case' do
          bodies.each do |body|
            expect(body).not_to match(/^[a-z]/)
          end
        end

        it 'ends with a punctuation' do
          bodies.each do |body|
            expect(body).to match(/[\.\!]$/)
          end
        end
      end
    end
  end
end
