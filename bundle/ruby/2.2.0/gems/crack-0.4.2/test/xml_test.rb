require 'test_helper'

describe Crack::XML do
  it "should transform a simple tag with content" do
    xml = "<tag>This is the contents</tag>"
    Crack::XML.parse(xml).must_equal({ 'tag' => 'This is the contents' })
  end

  it "should work with cdata tags" do
    xml = <<-END
      <tag>
      <![CDATA[
        text inside cdata
      ]]>
      </tag>
    END
    Crack::XML.parse(xml)["tag"].strip.must_equal "text inside cdata"
  end

  it "should transform a simple tag with attributes" do
    xml = "<tag attr1='1' attr2='2'></tag>"
    hash = { 'tag' => { 'attr1' => '1', 'attr2' => '2' } }
    Crack::XML.parse(xml).must_equal hash
  end

  it "should transform repeating siblings into an array" do
    xml =<<-XML
      <opt>
        <user login="grep" fullname="Gary R Epstein" />
        <user login="stty" fullname="Simon T Tyson" />
      </opt>
    XML

    Crack::XML.parse(xml)['opt']['user'].class.must_equal Array

    hash = {
      'opt' => {
        'user' => [{
          'login'    => 'grep',
          'fullname' => 'Gary R Epstein'
        },{
          'login'    => 'stty',
          'fullname' => 'Simon T Tyson'
        }]
      }
    }

    Crack::XML.parse(xml).must_equal hash
  end

  it "should not transform non-repeating siblings into an array" do
    xml =<<-XML
      <opt>
        <user login="grep" fullname="Gary R Epstein" />
      </opt>
    XML

    Crack::XML.parse(xml)['opt']['user'].class.must_equal Hash

    hash = {
      'opt' => {
        'user' => {
          'login' => 'grep',
          'fullname' => 'Gary R Epstein'
        }
      }
    }

    Crack::XML.parse(xml).must_equal hash
  end

  describe "Parsing xml with text and attributes" do
    before do
      xml =<<-XML
        <opt>
          <user login="grep">Gary R Epstein</user>
          <user>Simon T Tyson</user>
        </opt>
      XML
      @data = Crack::XML.parse(xml)
    end

    it "correctly parse text nodes" do
      @data.must_equal({
        'opt' => {
          'user' => [
            'Gary R Epstein',
            'Simon T Tyson'
          ]
        }
      })
    end

    it "be parse attributes for text node if present" do
      @data['opt']['user'][0].attributes.must_equal({'login' => 'grep'})
    end

    it "default attributes to empty hash if not present" do
      @data['opt']['user'][1].attributes.must_equal({})
    end

    it "add 'attributes' accessor methods to parsed instances of String" do
      @data['opt']['user'][0].respond_to?(:attributes).must_equal(true)
      @data['opt']['user'][0].respond_to?(:attributes=).must_equal(true)
    end

    it "not add 'attributes' accessor methods to all instances of String" do
      "some-string".respond_to?(:attributes).must_equal(false)
      "some-string".respond_to?(:attributes=).must_equal(false)
    end
  end

  it "should typecast an integer" do
    xml = "<tag type='integer'>10</tag>"
    Crack::XML.parse(xml)['tag'].must_equal 10
  end

  it "should typecast a true boolean" do
    xml = "<tag type='boolean'>true</tag>"
    Crack::XML.parse(xml)['tag'].must_equal(true)
  end

  it "should typecast a false boolean" do
    ["false"].each do |w|
      Crack::XML.parse("<tag type='boolean'>#{w}</tag>")['tag'].must_equal(false)
    end
  end

  it "should typecast a datetime" do
    xml = "<tag type='datetime'>2007-12-31 10:32</tag>"
    Crack::XML.parse(xml)['tag'].must_equal Time.parse( '2007-12-31 10:32' ).utc
  end

  it "should typecast a date" do
    xml = "<tag type='date'>2007-12-31</tag>"
    Crack::XML.parse(xml)['tag'].must_equal Date.parse('2007-12-31')
  end

  xml_entities = {
    "<" => "&lt;",
    ">" => "&gt;",
    '"' => "&quot;",
    "'" => "&apos;",
    "&" => "&amp;"
  }
  it "should unescape html entities" do
    xml_entities.each do |k,v|
      xml = "<tag>Some content #{v}</tag>"
      Crack::XML.parse(xml)['tag'].must_match Regexp.new(k)
    end
  end

  it "should unescape XML entities in attributes" do
    xml_entities.each do |k,v|
      xml = "<tag attr='Some content #{v}'></tag>"
      Crack::XML.parse(xml)['tag']['attr'].must_match Regexp.new(k)
    end
  end

  it "should undasherize keys as tags" do
    xml = "<tag-1>Stuff</tag-1>"
    Crack::XML.parse(xml).keys.must_include( 'tag_1' )
  end

  it "should undasherize keys as attributes" do
    xml = "<tag1 attr-1='1'></tag1>"
    Crack::XML.parse(xml)['tag1'].keys.must_include( 'attr_1')
  end

  it "should undasherize keys as tags and attributes" do
    xml = "<tag-1 attr-1='1'></tag-1>"
    Crack::XML.parse(xml).keys.must_include( 'tag_1' )
    Crack::XML.parse(xml)['tag_1'].keys.must_include( 'attr_1')
  end

  it "should render nested content correctly" do
    xml = "<root><tag1>Tag1 Content <em><strong>This is strong</strong></em></tag1></root>"
    Crack::XML.parse(xml)['root']['tag1'].must_equal "Tag1 Content <em><strong>This is strong</strong></em>"
  end

  it "should render nested content with splshould text nodes correctly" do
    xml = "<root>Tag1 Content<em>Stuff</em> Hi There</root>"
    Crack::XML.parse(xml)['root'].must_equal "Tag1 Content<em>Stuff</em> Hi There"
  end

  it "should ignore attributes when a child is a text node" do
    xml = "<root attr1='1'>Stuff</root>"
    Crack::XML.parse(xml).must_equal({ "root" => "Stuff" })
  end

  it "should ignore attributes when any child is a text node" do
    xml = "<root attr1='1'>Stuff <em>in italics</em></root>"
    Crack::XML.parse(xml).must_equal({ "root" => "Stuff <em>in italics</em>" })
  end

  it "should correctly transform multiple children" do
    xml = <<-XML
    <user gender='m'>
      <age type='integer'>35</age>
      <name>Home Simpson</name>
      <dob type='date'>1988-01-01</dob>
      <joined-at type='datetime'>2000-04-28 23:01</joined-at>
      <is-cool type='boolean'>true</is-cool>
    </user>
    XML

    hash =  {
      "user" => {
        "gender"    => "m",
        "age"       => 35,
        "name"      => "Home Simpson",
        "dob"       => Date.parse('1988-01-01'),
        "joined_at" => Time.parse("2000-04-28 23:01"),
        "is_cool"   => true
      }
    }

    Crack::XML.parse(xml).must_equal hash
  end

  it "should properly handle nil values (ActiveSupport Compatible)" do
    topic_xml = <<-EOT
      <topic>
        <title></title>
        <id type="integer"></id>
        <approved type="boolean"></approved>
        <written-on type="date"></written-on>
        <viewed-at type="datetime"></viewed-at>
        <parent-id></parent-id>
      </topic>
    EOT

    expected_topic_hash = {
      'title'      => nil,
      'id'         => nil,
      'approved'   => nil,
      'written_on' => nil,
      'viewed_at'  => nil,
      'parent_id'  => nil
    }
    Crack::XML.parse(topic_xml)["topic"].must_equal expected_topic_hash
  end

  it "should handle a single record from xml (ActiveSupport Compatible)" do
    topic_xml = <<-EOT
      <topic>
        <title>The First Topic</title>
        <author-name>David</author-name>
        <id type="integer">1</id>
        <approved type="boolean"> true </approved>
        <replies-count type="integer">0</replies-count>
        <replies-close-in type="integer">2592000000</replies-close-in>
        <written-on type="date">2003-07-16</written-on>
        <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
        <author-email-address>david@loudthinking.com</author-email-address>
        <parent-id></parent-id>
        <ad-revenue type="decimal">1.5</ad-revenue>
        <optimum-viewing-angle type="float">135</optimum-viewing-angle>
        <resident type="symbol">yes</resident>
      </topic>
    EOT

    expected_topic_hash = {
      'title' => "The First Topic",
      'author_name' => "David",
      'id' => 1,
      'approved' => true,
      'replies_count' => 0,
      'replies_close_in' => 2592000000,
      'written_on' => Date.new(2003, 7, 16),
      'viewed_at' => Time.utc(2003, 7, 16, 9, 28),
      'author_email_address' => "david@loudthinking.com",
      'parent_id' => nil,
      'ad_revenue' => BigDecimal("1.50"),
      'optimum_viewing_angle' => 135.0,
      'resident' => 'yes',
    }

    Crack::XML.parse(topic_xml)["topic"].each do |k,v|
      v.must_equal expected_topic_hash[k]
    end
  end

  it "should handle multiple records (ActiveSupport Compatible)" do
    topics_xml = <<-EOT
      <topics type="array">
        <topic>
          <title>The First Topic</title>
          <author-name>David</author-name>
          <id type="integer">1</id>
          <approved type="boolean">false</approved>
          <replies-count type="integer">0</replies-count>
          <replies-close-in type="integer">2592000000</replies-close-in>
          <written-on type="date">2003-07-16</written-on>
          <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
          <content>Have a nice day</content>
          <author-email-address>david@loudthinking.com</author-email-address>
          <parent-id nil="true"></parent-id>
        </topic>
        <topic>
          <title>The Second Topic</title>
          <author-name>Jason</author-name>
          <id type="integer">1</id>
          <approved type="boolean">false</approved>
          <replies-count type="integer">0</replies-count>
          <replies-close-in type="integer">2592000000</replies-close-in>
          <written-on type="date">2003-07-16</written-on>
          <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
          <content>Have a nice day</content>
          <author-email-address>david@loudthinking.com</author-email-address>
          <parent-id></parent-id>
        </topic>
      </topics>
    EOT

    expected_topic_hash = {
      'title' => "The First Topic",
      'author_name' => "David",
      'id' => 1,
      'approved' => false,
      'replies_count' => 0,
      'replies_close_in' => 2592000000,
      'written_on' => Date.new(2003, 7, 16),
      'viewed_at' => Time.utc(2003, 7, 16, 9, 28),
      'content' => "Have a nice day",
      'author_email_address' => "david@loudthinking.com",
      'parent_id' => nil
    }
    # puts Crack::XML.parse(topics_xml)['topics'].first.inspect
    Crack::XML.parse(topics_xml)["topics"].first.each do |k,v|
      v.must_equal expected_topic_hash[k]
    end
  end

  it "should handle a single record from_xml with attributes other than type (ActiveSupport Compatible)" do
    topic_xml = <<-EOT
    <rsp stat="ok">
      <photos page="1" pages="1" perpage="100" total="16">
        <photo id="175756086" owner="55569174@N00" secret="0279bf37a1" server="76" title="Colored Pencil PhotoBooth Fun" ispublic="1" isfriend="0" isfamily="0"/>
      </photos>
    </rsp>
    EOT

    expected_topic_hash = {
      'id' => "175756086",
      'owner' => "55569174@N00",
      'secret' => "0279bf37a1",
      'server' => "76",
      'title' => "Colored Pencil PhotoBooth Fun",
      'ispublic' => "1",
      'isfriend' => "0",
      'isfamily' => "0",
    }
    Crack::XML.parse(topic_xml)["rsp"]["photos"]["photo"].each do |k,v|
      v.must_equal expected_topic_hash[k]
    end
  end

  it "should handle an emtpy array (ActiveSupport Compatible)" do
    blog_xml = <<-XML
      <blog>
        <posts type="array"></posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => []}}
    Crack::XML.parse(blog_xml).must_equal expected_blog_hash
  end

  it "should handle empty array with whitespace from xml (ActiveSupport Compatible)" do
    blog_xml = <<-XML
      <blog>
        <posts type="array">
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => []}}
    Crack::XML.parse(blog_xml).must_equal expected_blog_hash
  end

  it "should handle array with one entry from_xml (ActiveSupport Compatible)" do
    blog_xml = <<-XML
      <blog>
        <posts type="array">
          <post>a post</post>
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => ["a post"]}}
    Crack::XML.parse(blog_xml).must_equal expected_blog_hash
  end

  it "should handle array with multiple entries from xml (ActiveSupport Compatible)" do
    blog_xml = <<-XML
      <blog>
        <posts type="array">
          <post>a post</post>
          <post>another post</post>
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => ["a post", "another post"]}}
    Crack::XML.parse(blog_xml).must_equal expected_blog_hash
  end

  it "should handle file types (ActiveSupport Compatible)" do
    blog_xml = <<-XML
      <blog>
        <logo type="file" name="logo.png" content_type="image/png">
        </logo>
      </blog>
    XML
    hash = Crack::XML.parse(blog_xml)
    hash.keys.must_include('blog')
    hash['blog'].keys.must_include('logo')

    file = hash['blog']['logo']
    file.original_filename.must_equal 'logo.png'
    file.content_type.must_equal 'image/png'
  end

  it "should handle file from xml with defaults (ActiveSupport Compatible)" do
    blog_xml = <<-XML
      <blog>
        <logo type="file">
        </logo>
      </blog>
    XML
    file = Crack::XML.parse(blog_xml)['blog']['logo']
    file.original_filename.must_equal 'untitled'
    file.content_type.must_equal 'application/octet-stream'
  end

  it "should handle xsd like types from xml (ActiveSupport Compatible)" do
    bacon_xml = <<-EOT
    <bacon>
      <weight type="double">0.5</weight>
      <price type="decimal">12.50</price>
      <chunky type="boolean"> 1 </chunky>
      <expires-at type="dateTime">2007-12-25T12:34:56+0000</expires-at>
      <notes type="string"></notes>
      <illustration type="base64Binary">YmFiZS5wbmc=</illustration>
    </bacon>
    EOT

    expected_bacon_hash = {
      'weight' => 0.5,
      'chunky' => true,
      'price' => BigDecimal("12.50"),
      'expires_at' => Time.utc(2007,12,25,12,34,56),
      'notes' => "",
      'illustration' => "babe.png"
    }

    Crack::XML.parse(bacon_xml)["bacon"].must_equal expected_bacon_hash
  end

  it "should let type trickle through when unknown (ActiveSupport Compatible)" do
    product_xml = <<-EOT
    <product>
      <weight type="double">0.5</weight>
      <image type="ProductImage"><filename>image.gif</filename></image>

    </product>
    EOT

    expected_product_hash = {
      'weight' => 0.5,
      'image' => {'type' => 'ProductImage', 'filename' => 'image.gif' },
    }

    Crack::XML.parse(product_xml)["product"].must_equal expected_product_hash
  end

  it "should handle unescaping from xml (ActiveResource Compatible)" do
    xml_string = '<person><bare-string>First &amp; Last Name</bare-string><pre-escaped-string>First &amp;amp; Last Name</pre-escaped-string></person>'
    expected_hash = {
      'bare_string'        => 'First & Last Name',
      'pre_escaped_string' => 'First &amp; Last Name'
    }

    Crack::XML.parse(xml_string)['person'].must_equal expected_hash
  end

  it "handle an empty xml string" do
    Crack::XML.parse('').must_equal({})
  end

  # As returned in the response body by the unfuddle XML API when creating objects
  it "handle an xml string containing a single space" do
    Crack::XML.parse(' ').must_equal({})
  end

  it "can dump parsed xml" do
    xml = <<-XML
      <blog>
        <posts language="english">I like big butts and I cannot Lie</posts>
      </blog>
    XML

    Marshal.dump(Crack::XML.parse(xml))
  end

  it "properly handles a node with type == file that has children" do
    # Example is an excerpt from a problematic kvm domain config file
    example_xml = <<-EOT
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source file='/tmp/cdrom.iso'/>
    </disk>
    EOT

    Crack::XML.parse(example_xml).must_equal({"disk"=>{"driver"=>{"name"=>"qemu", "type"=>"raw", "cache"=>"none", "io"=>"native"}, "source"=>{"file"=>"/tmp/cdrom.iso"}, "type"=>"file", "device"=>"cdrom"}})
  end
end
