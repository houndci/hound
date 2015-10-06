require 'inline_svg'

class WorkingCustomTransform < InlineSvg::CustomTransformation
  def transform(doc)
    doc = Nokogiri::XML::Document.parse(doc.to_html)
    svg = doc.at_css 'svg'
    svg['custom'] = value
    doc
  end
end

describe InlineSvg::ActionView::Helpers do

  let(:helper) { ( Class.new { include InlineSvg::ActionView::Helpers } ).new }

  describe "#inline_svg" do
    
    context "when passed the name of an SVG that does not exist" do
      it "returns an empty, html safe, SVG document as a placeholder" do
        allow(InlineSvg::AssetFile).to receive(:named).with('some-missing-file').and_raise(InlineSvg::AssetFile::FileNotFound.new)
        output = helper.inline_svg('some-missing-file')
        expect(output).to eq "<svg><!-- SVG file not found: 'some-missing-file' --></svg>"
        expect(output).to be_html_safe
      end
    end

    context "when passed an existing SVG file" do

      context "and no options" do
        it "returns a html safe version of the file's contents" do
          example_file = <<-SVG
<svg xmlns="http://www.w3.org/2000/svg" role="presentation" xml:lang="en"><!-- This is a comment --></svg>
SVG
          allow(InlineSvg::AssetFile).to receive(:named).with('some-file').and_return(example_file)
          expect(helper.inline_svg('some-file')).to eq example_file
        end
      end

      context "and the 'title' option" do
        it "adds the title node to the SVG output" do
          input_svg = <<-SVG
<svg xmlns="http://www.w3.org/2000/svg" role="presentation" xml:lang="en"></svg>
SVG
          expected_output = <<-SVG
<svg xmlns="http://www.w3.org/2000/svg" role="presentation" xml:lang="en"><title>A title</title></svg>
SVG
          allow(InlineSvg::AssetFile).to receive(:named).with('some-file').and_return(input_svg)
          expect(helper.inline_svg('some-file', title: 'A title')).to eq expected_output
        end
      end

      context "and the 'desc' option" do
        it "adds the description node to the SVG output" do
          input_svg = <<-SVG
<svg xmlns="http://www.w3.org/2000/svg" role="presentation" xml:lang="en"></svg>
SVG
          expected_output = <<-SVG
<svg xmlns="http://www.w3.org/2000/svg" role="presentation" xml:lang="en"><desc>A description</desc></svg>
SVG
          allow(InlineSvg::AssetFile).to receive(:named).with('some-file').and_return(input_svg)
          expect(helper.inline_svg('some-file', desc: 'A description')).to eq expected_output
        end
      end

      context "and the 'nocomment' option" do
        it "strips comments and other unknown/unsafe nodes from the output" do
          input_svg = <<-SVG
<svg xmlns="http://www.w3.org/2000/svg" role="presentation" xml:lang="en"><!-- This is a comment --></svg>
SVG
          expected_output = <<-SVG
<svg xmlns="http://www.w3.org/2000/svg" xml:lang="en"></svg>
SVG
          allow(InlineSvg::AssetFile).to receive(:named).with('some-file').and_return(input_svg)
          expect(helper.inline_svg('some-file', nocomment: true)).to eq expected_output
        end
      end

      context "and all options" do
        it "applies all expected transformations to the output" do
          input_svg = <<-SVG
<svg xmlns="http://www.w3.org/2000/svg" role="presentation" xml:lang="en"><!-- This is a comment --></svg>
SVG
          expected_output = <<-SVG
<svg xmlns="http://www.w3.org/2000/svg" xml:lang="en"><title>A title</title>
<desc>A description</desc></svg>
SVG
          allow(InlineSvg::AssetFile).to receive(:named).with('some-file').and_return(input_svg)
          expect(helper.inline_svg('some-file', title: 'A title', desc: 'A description', nocomment: true)).to eq expected_output
        end
      end

      context "with custom transformations" do
        before(:each) do
          InlineSvg.configure do |config|
            config.add_custom_transformation({attribute: :custom, transform: WorkingCustomTransform})
          end
        end

        after(:each) do
          InlineSvg.reset_configuration!
        end

        it "applies custm transformations to the output" do
          input_svg = <<-SVG
<svg></svg>
SVG
          expected_output = <<-SVG
<svg custom="some value"></svg>
SVG
          allow(InlineSvg::AssetFile).to receive(:named).with('some-file').and_return(input_svg)
          expect(helper.inline_svg('some-file', custom: 'some value')).to eq expected_output
        end
      end
    end
  end
end
