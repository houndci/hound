shared_examples_for "a parser" do |parser|

  before do
    begin
      MultiXml.parser = parser
    rescue LoadError
      pending "Parser #{parser} couldn't be loaded"
    end
  end

  describe ".parse" do
    context "a blank string" do
      before do
        @xml = ''
      end

      it "returns an empty Hash" do
        expect(MultiXml.parse(@xml)).to eq({})
      end
    end

    context "a whitespace string" do
      before do
        @xml = ' '
      end

      it "returns an empty Hash" do
        expect(MultiXml.parse(@xml)).to eq({})
      end
    end

    context "an invalid XML document" do
      before do
        @xml = '<open></close>'
      end

      it "raises MultiXml::ParseError" do
        expect{MultiXml.parse(@xml)}.to raise_error(MultiXml::ParseError)
      end
    end

    context "a valid XML document" do
      before do
        @xml = '<user/>'
      end

      it "parses correctly" do
        expect(MultiXml.parse(@xml)).to eq({'user' => nil})
      end

      context "with CDATA" do
        before do
          @xml = '<user><![CDATA[Erik Michaels-Ober]]></user>'
        end

        it "returns the correct CDATA" do
          expect(MultiXml.parse(@xml)['user']).to eq("Erik Michaels-Ober")
        end
      end

      context "element with the same inner element and attribute name" do
        before do
          @xml = "<user name='John'><name>Smith</name></user>"
        end

        it "returns nams as Array" do
          expect(MultiXml.parse(@xml)['user']['name']).to eq ['John', 'Smith']
        end
      end

      context "with content" do
        before do
          @xml = '<user>Erik Michaels-Ober</user>'
        end

        it "returns the correct content" do
          expect(MultiXml.parse(@xml)['user']).to eq("Erik Michaels-Ober")
        end
      end

      context "with an attribute" do
        before do
          @xml = '<user name="Erik Michaels-Ober"/>'
        end

        it "returns the correct attribute" do
          expect(MultiXml.parse(@xml)['user']['name']).to eq("Erik Michaels-Ober")
        end
      end

      context "with multiple attributes" do
        before do
          @xml = '<user name="Erik Michaels-Ober" screen_name="sferik"/>'
        end

        it "returns the correct attributes" do
          expect(MultiXml.parse(@xml)['user']['name']).to eq("Erik Michaels-Ober")
          expect(MultiXml.parse(@xml)['user']['screen_name']).to eq("sferik")
        end
      end

      context "typecast management" do
        before do
          @xml = %Q{
            <global-settings>
              <group>
                <name>Settings</name>
                <setting type="string">
                  <description>Test</description>
                </setting>
              </group>
            </global-settings>
          }
        end

        context "with :typecast_xml_value => true" do
          before do
            @setting = MultiXml.parse(@xml)["global_settings"]["group"]["setting"]
          end

          it { expect(@setting).to eq "" }
        end

        context "with :typecast_xml_value => false" do
          before do
            @setting = MultiXml.parse(@xml, :typecast_xml_value => false)["global_settings"]["group"]["setting"]
          end

          it { expect(@setting).to eq({"type"=>"string", "description"=>{"__content__"=>"Test"}}) }
        end
      end

      context "with :symbolize_keys => true" do
        before do
          @xml = '<users><user name="Erik Michaels-Ober"/><user><name>Wynn Netherland</name></user></users>'
        end

        it "symbolizes keys" do
          expect(MultiXml.parse(@xml, :symbolize_keys => true)).to eq({:users => {:user => [{:name => "Erik Michaels-Ober"}, {:name => "Wynn Netherland"}]}})
        end
      end

      context "with an attribute type=\"boolean\"" do
        %w(true false).each do |boolean|
          context "when #{boolean}" do
            it "returns #{boolean}" do
              xml = "<tag type=\"boolean\">#{boolean}</tag>"
              expect(MultiXml.parse(xml)['tag']).to instance_eval("be_#{boolean}")
            end
          end
        end

        context "when 1" do
          before do
            @xml = '<tag type="boolean">1</tag>'
          end

          it "returns true" do
            expect(MultiXml.parse(@xml)['tag']).to be_true
          end
        end

        context "when 0" do
          before do
            @xml = '<tag type="boolean">0</tag>'
          end

          it "returns false" do
            expect(MultiXml.parse(@xml)['tag']).to be_false
          end
        end
      end

      context "with an attribute type=\"integer\"" do
        context "with a positive integer" do
          before do
            @xml = '<tag type="integer">1</tag>'
          end

          it "returns a Fixnum" do
            expect(MultiXml.parse(@xml)['tag']).to be_a(Fixnum)
          end

          it "returns a positive number" do
            expect(MultiXml.parse(@xml)['tag']).to be > 0
          end

          it "returns the correct number" do
            expect(MultiXml.parse(@xml)['tag']).to eq(1)
          end
        end

        context "with a negative integer" do
          before do
            @xml = '<tag type="integer">-1</tag>'
          end

          it "returns a Fixnum" do
            expect(MultiXml.parse(@xml)['tag']).to be_a(Fixnum)
          end

          it "returns a negative number" do
            expect(MultiXml.parse(@xml)['tag']).to be < 0
          end

          it "returns the correct number" do
            expect(MultiXml.parse(@xml)['tag']).to eq(-1)
          end
        end
      end

      context "with an attribute type=\"string\"" do
        before do
          @xml = '<tag type="string"></tag>'
        end

        it "returns a String" do
          expect(MultiXml.parse(@xml)['tag']).to be_a(String)
        end

        it "returns the correct string" do
          expect(MultiXml.parse(@xml)['tag']).to eq("")
        end
      end

      context "with an attribute type=\"date\"" do
        before do
          @xml = '<tag type="date">1970-01-01</tag>'
        end

        it "returns a Date" do
          expect(MultiXml.parse(@xml)['tag']).to be_a(Date)
        end

        it "returns the correct date" do
          expect(MultiXml.parse(@xml)['tag']).to eq(Date.parse('1970-01-01'))
        end
      end

      context "with an attribute type=\"datetime\"" do
        before do
          @xml = '<tag type="datetime">1970-01-01 00:00</tag>'
        end

        it "returns a Time" do
          expect(MultiXml.parse(@xml)['tag']).to be_a(Time)
        end

        it "returns the correct time" do
          expect(MultiXml.parse(@xml)['tag']).to eq(Time.parse('1970-01-01 00:00'))
        end
      end

      context "with an attribute type=\"dateTime\"" do
        before do
          @xml = '<tag type="datetime">1970-01-01 00:00</tag>'
        end

        it "returns a Time" do
          expect(MultiXml.parse(@xml)['tag']).to be_a(Time)
        end

        it "returns the correct time" do
          expect(MultiXml.parse(@xml)['tag']).to eq(Time.parse('1970-01-01 00:00'))
        end
      end

      context "with an attribute type=\"double\"" do
        before do
          @xml = '<tag type="double">3.14159265358979</tag>'
        end

        it "returns a Float" do
          expect(MultiXml.parse(@xml)['tag']).to be_a(Float)
        end

        it "returns the correct number" do
          expect(MultiXml.parse(@xml)['tag']).to eq(3.14159265358979)
        end
      end

      context "with an attribute type=\"decimal\"" do
        before do
          @xml = '<tag type="decimal">3.14159265358979</tag>'
        end

        it "returns a BigDecimal" do
          expect(MultiXml.parse(@xml)['tag']).to be_a(BigDecimal)
        end

        it "returns the correct number" do
          expect(MultiXml.parse(@xml)['tag']).to eq(3.14159265358979)
        end
      end

      context "with an attribute type=\"base64Binary\"" do
        before do
          @xml = '<tag type="base64Binary">aW1hZ2UucG5n</tag>'
        end

        it "returns a String" do
          expect(MultiXml.parse(@xml)['tag']).to be_a(String)
        end

        it "returns the correct string" do
          expect(MultiXml.parse(@xml)['tag']).to eq("image.png")
        end
      end

      context "with an attribute type=\"yaml\"" do
        before do
          @xml = "<tag type=\"yaml\">--- \n1: returns an integer\n:message: Have a nice day\narray: \n- has-dashes: true\n  has_underscores: true\n</tag>"
        end

        it "raises MultiXML::DisallowedTypeError by default" do
          expect{ MultiXml.parse(@xml)['tag'] }.to raise_error(MultiXml::DisallowedTypeError)
        end

        it "returns the correctly parsed YAML when the type is allowed" do
          expect(MultiXml.parse(@xml, :disallowed_types => [])['tag']).to eq({:message => "Have a nice day", 1 => "returns an integer", "array" => [{"has-dashes" => true, "has_underscores" => true}]})
        end
      end

      context "with an attribute type=\"symbol\"" do
        before do
          @xml = "<tag type=\"symbol\">my_symbol</tag>"
        end

        it "raises MultiXML::DisallowedTypeError" do
          expect{ MultiXml.parse(@xml)['tag'] }.to raise_error(MultiXml::DisallowedTypeError)
        end

        it "returns the correctly parsed Symbol when the type is allowed" do
          expect(MultiXml.parse(@xml, :disallowed_types => [])['tag']).to eq(:my_symbol)
        end
      end

      context "with an attribute type=\"file\"" do
        before do
          @xml = '<tag type="file" name="data.txt" content_type="text/plain">ZGF0YQ==</tag>'
        end

        it "returns a StringIO" do
          expect(MultiXml.parse(@xml)['tag']).to be_a(StringIO)
        end

        it "is decoded correctly" do
          expect(MultiXml.parse(@xml)['tag'].string).to eq('data')
        end

        it "has the correct file name" do
          expect(MultiXml.parse(@xml)['tag'].original_filename).to eq('data.txt')
        end

        it "has the correct content type" do
          expect(MultiXml.parse(@xml)['tag'].content_type).to eq('text/plain')
        end

        context "with missing name and content type" do
          before do
            @xml = '<tag type="file">ZGF0YQ==</tag>'
          end

          it "returns a StringIO" do
            expect(MultiXml.parse(@xml)['tag']).to be_a(StringIO)
          end

          it "is decoded correctly" do
            expect(MultiXml.parse(@xml)['tag'].string).to eq('data')
          end

          it "has the default file name" do
            expect(MultiXml.parse(@xml)['tag'].original_filename).to eq('untitled')
          end

          it "has the default content type" do
            expect(MultiXml.parse(@xml)['tag'].content_type).to eq('application/octet-stream')
          end
        end
      end

      context "with an attribute type=\"array\"" do
        before do
          @xml = '<users type="array"><user>Erik Michaels-Ober</user><user>Wynn Netherland</user></users>'
        end

        it "returns an Array" do
          expect(MultiXml.parse(@xml)['users']).to be_a(Array)
        end

        it "returns the correct array" do
          expect(MultiXml.parse(@xml)['users']).to eq(["Erik Michaels-Ober", "Wynn Netherland"])
        end
      end

      context "with an attribute type=\"array\" in addition to other attributes" do
        before do
          @xml = '<users type="array" foo="bar"><user>Erik Michaels-Ober</user><user>Wynn Netherland</user></users>'
        end

        it "returns an Array" do
          expect(MultiXml.parse(@xml)['users']).to be_a(Array)
        end

        it "returns the correct array" do
          expect(MultiXml.parse(@xml)['users']).to eq(["Erik Michaels-Ober", "Wynn Netherland"])
        end
      end

      context "with an attribute type=\"array\" containing only one item" do
        before do
          @xml = '<users type="array"><user>Erik Michaels-Ober</user></users>'
        end

        it "returns an Array" do
          expect(MultiXml.parse(@xml)['users']).to be_a(Array)
        end

        it "returns the correct array" do
          expect(MultiXml.parse(@xml)['users']).to eq(["Erik Michaels-Ober"])
        end
      end

      %w(integer boolean date datetime file).each do |type|
        context "with an empty attribute type=\"#{type}\"" do
          before do
            @xml = "<tag type=\"#{type}\"/>"
          end

          it "returns nil" do
            expect(MultiXml.parse(@xml)['tag']).to be_nil
          end
        end
      end

      %w{yaml symbol}.each do |type|
        context "with an empty attribute type=\"#{type}\"" do
          before do
            @xml = "<tag type=\"#{type}\"/>"
          end

          it "raises MultiXml::DisallowedTypeError by default" do
            expect{ MultiXml.parse(@xml)['tag']}.to raise_error(MultiXml::DisallowedTypeError)
          end

          it "returns nil when the type is allowed" do
            expect(MultiXml.parse(@xml, :disallowed_types => [])['tag']).to be_nil
          end
        end
      end

      context "with an empty attribute type=\"array\"" do
        before do
          @xml = '<tag type="array"/>'
        end

        it "returns an empty Array" do
          expect(MultiXml.parse(@xml)['tag']).to eq([])
        end

        context "with whitespace" do
          before do
            @xml = '<tag type="array"> </tag>'
          end

          it "returns an empty Array" do
            expect(MultiXml.parse(@xml)['tag']).to eq([])
          end
        end
      end

      context "with XML entities" do
        before do
          @xml_entities = {
            "<" => "&lt;",
            ">" => "&gt;",
            '"' => "&quot;",
            "'" => "&apos;",
            "&" => "&amp;"
          }
        end

        context "in content" do
          it "returns unescaped XML entities" do
            @xml_entities.each do |key, value|
              xml = "<tag>#{value}</tag>"
              expect(MultiXml.parse(xml)['tag']).to eq(key)
            end
          end
        end

        context "in attribute" do
          it "returns unescaped XML entities" do
            @xml_entities.each do |key, value|
              xml = "<tag attribute=\"#{value}\"/>"
              expect(MultiXml.parse(xml)['tag']['attribute']).to eq(key)
            end
          end
        end
      end


      context "with dasherized tag" do
        before do
          @xml = '<tag-1/>'
        end

        it "returns undasherize tag" do
          expect(MultiXml.parse(@xml).keys).to include('tag_1')
        end
      end

      context "with dasherized attribute" do
        before do
          @xml = '<tag attribute-1="1"></tag>'
        end

        it "returns undasherize attribute" do
          expect(MultiXml.parse(@xml)['tag'].keys).to include('attribute_1')
        end
      end

      context "with children" do
        context "with attributes" do
          before do
            @xml = '<users><user name="Erik Michaels-Ober"/></users>'
          end

          it "returns the correct attributes" do
            expect(MultiXml.parse(@xml)['users']['user']['name']).to eq("Erik Michaels-Ober")
          end
        end

        context "with text" do
          before do
            @xml = '<user><name>Erik Michaels-Ober</name></user>'
          end

          it "returns the correct text" do
            expect(MultiXml.parse(@xml)['user']['name']).to eq("Erik Michaels-Ober")
          end
        end

        context "with an unrecognized attribute type" do
          before do
            @xml = '<user type="admin"><name>Erik Michaels-Ober</name></user>'
          end

          it "passes through the type" do
            expect(MultiXml.parse(@xml)['user']['type']).to eq('admin')
          end
        end

        context "with attribute tags on content nodes" do
          context "non 'type' attributes" do
            before do
              @xml = <<-XML
                <options>
                  <value currency='USD'>123</value>
                  <value number='percent'>0.123</value>
                </options>
              XML
              @parsed_xml = MultiXml.parse(@xml)
            end

            it "adds the attributes to the value hash" do
              expect(@parsed_xml['options']['value'][0]['__content__']).to eq('123')
              expect(@parsed_xml['options']['value'][0]['currency']).to eq('USD')
              expect(@parsed_xml['options']['value'][1]['__content__']).to eq('0.123')
              expect(@parsed_xml['options']['value'][1]['number']).to eq('percent')
            end
          end

          context "unrecognized type attributes" do
            before do
              @xml = <<-XML
                <options>
                  <value type='USD'>123</value>
                  <value type='percent'>0.123</value>
                  <value currency='USD'>123</value>
                </options>
              XML
              @parsed_xml = MultiXml.parse(@xml)
            end

            it "adds the attributes to the value hash passing through the type" do
              expect(@parsed_xml['options']['value'][0]['__content__']).to eq('123')
              expect(@parsed_xml['options']['value'][0]['type']).to eq('USD')
              expect(@parsed_xml['options']['value'][1]['__content__']).to eq('0.123')
              expect(@parsed_xml['options']['value'][1]['type']).to eq('percent')
              expect(@parsed_xml['options']['value'][2]['__content__']).to eq('123')
              expect(@parsed_xml['options']['value'][2]['currency']).to eq('USD')
            end
          end

          context "mixing attributes and non-attributes content nodes type attributes" do
            before do
              @xml = <<-XML
                <options>
                  <value type='USD'>123</value>
                  <value type='percent'>0.123</value>
                  <value>123</value>
                </options>
              XML
              @parsed_xml = MultiXml.parse(@xml)
            end

            it "adds the attributes to the value hash passing through the type" do
              expect(@parsed_xml['options']['value'][0]['__content__']).to eq('123')
              expect(@parsed_xml['options']['value'][0]['type']).to eq('USD')
              expect(@parsed_xml['options']['value'][1]['__content__']).to eq('0.123')
              expect(@parsed_xml['options']['value'][1]['type']).to eq('percent')
              expect(@parsed_xml['options']['value'][2]).to eq('123')
            end
          end

          context "mixing recognized type attribute and non-type attributes on content nodes" do
            before do
              @xml = <<-XML
                <options>
                  <value number='USD' type='integer'>123</value>
                </options>
              XML
              @parsed_xml = MultiXml.parse(@xml)
            end

            it "adds the the non-type attribute and remove the recognized type attribute and do the typecast" do
              expect(@parsed_xml['options']['value']['__content__']).to eq(123)
              expect(@parsed_xml['options']['value']['number']).to eq('USD')
            end
          end

          context "mixing unrecognized type attribute and non-type attributes on content nodes" do
            before do
              @xml = <<-XML
                <options>
                  <value number='USD' type='currency'>123</value>
                </options>
              XML
              @parsed_xml = MultiXml.parse(@xml)
            end

            it "adds the the non-type attributes and type attribute to the value hash" do
              expect(@parsed_xml['options']['value']['__content__']).to eq('123')
              expect(@parsed_xml['options']['value']['number']).to eq('USD')
              expect(@parsed_xml['options']['value']['type']).to eq('currency')
            end
          end
        end

        context "with newlines and whitespace" do
          before do
            @xml = <<-XML
              <user>
                <name>Erik Michaels-Ober</name>
              </user>
            XML
          end

          it "parses correctly" do
            expect(MultiXml.parse(@xml)).to eq({"user" => {"name" => "Erik Michaels-Ober"}})
          end
        end

        # Babies having babies
        context "with children" do
          before do
            @xml = '<users><user name="Erik Michaels-Ober"><status text="Hello"/></user></users>'
          end

          it "parses correctly" do
            expect(MultiXml.parse(@xml)).to eq({"users" => {"user" => {"name" => "Erik Michaels-Ober", "status" => {"text" => "Hello"}}}})
          end
        end
      end

      context "with sibling children" do
        before do
          @xml = '<users><user>Erik Michaels-Ober</user><user>Wynn Netherland</user></users>'
        end

        it "returns an Array" do
          expect(MultiXml.parse(@xml)['users']['user']).to be_a(Array)
        end

        it "parses correctly" do
          expect(MultiXml.parse(@xml)).to eq({"users" => {"user" => ["Erik Michaels-Ober", "Wynn Netherland"]}})
        end
      end

    end
  end

end
