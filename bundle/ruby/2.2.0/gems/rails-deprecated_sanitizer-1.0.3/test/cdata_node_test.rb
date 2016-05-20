require 'test_helper'
require 'rails/deprecated_sanitizer/html-scanner/html/node'

class CDATANodeTest < ActiveSupport::TestCase
  def setup
    @node = HTML::CDATA.new(nil, 0, 0, "<p>howdy</p>")
  end

  def test_to_s
    assert_equal "<![CDATA[<p>howdy</p>]]>", @node.to_s
  end

  def test_content
    assert_equal "<p>howdy</p>", @node.content
  end
end
