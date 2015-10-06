require 'helper'
require 'parser_shared_example'

class MockDecoder; end

describe "MultiXml" do
  context "Parsers" do
    it "picks a default parser" do
      expect(MultiXml.parser).to be_kind_of(Module)
      expect(MultiXml.parser).to respond_to(:parse)
    end

    it "defaults to the best available gem" do
      # Clear cache variable already set by previous tests
      MultiXml.send(:remove_instance_variable, :@parser)
      expect(MultiXml.parser.name).to eq('MultiXml::Parsers::Ox')
    end

    it "is settable via a symbol" do
      MultiXml.parser = :rexml
      expect(MultiXml.parser.name).to eq('MultiXml::Parsers::Rexml')
    end

    it "is settable via a class" do
      MultiXml.parser = MockDecoder
      expect(MultiXml.parser.name).to eq('MockDecoder')
    end
  end

  [['LibXML', 'libxml'],
   ['REXML', 'rexml/document'],
   ['Nokogiri', 'nokogiri'],
   ['Ox', 'ox']].each do |parser|
    begin
      require parser.last
      context "#{parser.first} parser" do
        it_behaves_like "a parser", parser.first
      end
    rescue LoadError => e
      puts "Tests not run for #{parser.first} due to a LoadError"
    end
  end
end
